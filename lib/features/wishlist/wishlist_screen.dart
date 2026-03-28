import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_card.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_providers.dart';
import '../expense/expense_providers.dart';
import 'wishlist_form_sheet.dart';
import 'wishlist_providers.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  static const _uuid = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final listAsync = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wishlist),
      ),
      body: listAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.card_giftcard,
              title: l10n.wishlistEmptyTitle,
              subtitle: l10n.wishlistEmptySubtitle,
            );
          }
          final open = items.where((w) => !w.purchased).toList()
            ..sort(_priorityCompare);
          final done = items.where((w) => w.purchased).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(wishlistProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (open.isNotEmpty) ...[
                  Text(l10n.wishlistPlanned,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...open.map((w) => _WishTile(
                        lang: lang,
                        item: w,
                        onEdit: () => _openForm(context, ref, w),
                        onPurchased: () =>
                            _markPurchasedFlow(context, ref, w),
                        onDelete: () => _delete(context, ref, w),
                      )),
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.wishlistPurchased,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...done.map((w) => _WishTile(
                        lang: lang,
                        item: w,
                        onEdit: () => _openForm(context, ref, w),
                        onPurchased: null,
                        onDelete: () => _delete(context, ref, w),
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  int _priorityCompare(WishlistItem a, WishlistItem b) {
    int weight(WishlistPriority p) {
      switch (p) {
        case WishlistPriority.high:
          return 0;
        case WishlistPriority.medium:
          return 1;
        case WishlistPriority.low:
          return 2;
      }
    }

    final c = weight(a.priority).compareTo(weight(b.priority));
    if (c != 0) return c;
    return a.name.compareTo(b.name);
  }

  void _openForm(BuildContext context, WidgetRef ref, WishlistItem? existing) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => WishlistFormSheet(existing: existing),
    ).then((_) {
      ref.invalidate(wishlistProvider);
      ref.invalidate(dashboardSummaryProvider);
    });
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WishlistItem w,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Remove "${w.name}" from the wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(financeRepositoryProvider).deleteWishlistItem(w.id);
      ref.invalidate(wishlistProvider);
    }
  }

  Future<void> _markPurchasedFlow(
    BuildContext context,
    WidgetRef ref,
    WishlistItem w,
  ) async {
    final addExpense = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as purchased'),
        content: const Text(
          'Also log this as an expense? You can set amount and category next.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, just mark'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add expense'),
          ),
        ],
      ),
    );
    if (addExpense == null || !context.mounted) return;

    var amount = w.estimatedPrice;
    var category = 'Shopping';
    final date = DateTime.now();
    final note = 'Wishlist: ${w.name}';

    if (addExpense) {
      final amountCtrl =
          TextEditingController(text: w.estimatedPrice.toString());
      var cat = category;
      final formKey = GlobalKey<FormState>();
      try {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return StatefulBuilder(
              builder: (context, setSt) {
                return AlertDialog(
                  title: const Text('Expense details'),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: amountCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Amount'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n <= 0) {
                              return 'Enter a positive amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: cat,
                          items: kExpenseCategories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setSt(() => cat = v ?? cat),
                          decoration:
                              const InputDecoration(labelText: 'Category'),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx, true);
                        }
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                );
              },
            );
          },
        );
        if (ok != true || !context.mounted) return;
        amount = double.parse(amountCtrl.text.trim());
        category = cat;
      } finally {
        amountCtrl.dispose();
      }
    }

    final repo = ref.read(financeRepositoryProvider);
    await repo.upsertWishlistItem(
      w.copyWith(
        purchased: true,
        purchasedAt: DateTime.now(),
      ),
    );
    if (addExpense) {
      await repo.upsertExpense(
        Expense(
          id: _uuid.v4(),
          amount: amount,
          category: category,
          date: date,
          note: note,
        ),
      );
    }
    ref.invalidate(wishlistProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(expenseListProvider);
  }
}

class _WishTile extends StatelessWidget {
  const _WishTile({
    required this.lang,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    this.onPurchased,
  });

  final String lang;
  final WishlistItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPurchased;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final chipColor = switch (item.priority) {
      WishlistPriority.high => scheme.errorContainer,
      WishlistPriority.medium => scheme.secondaryContainer,
      WishlistPriority.low => scheme.surfaceContainerHighest,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(item.priority.name), backgroundColor: chipColor),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatMoney(item.estimatedPrice, languageCode: lang),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (item.purchased && item.purchasedAt != null)
              Text(
                '${l10n.purchased} ${item.purchasedAt!.toLocal().toString().split(' ').first}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(l10n.edit),
                ),
                if (!item.purchased && onPurchased != null)
                  FilledButton.icon(
                    onPressed: onPurchased,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l10n.purchased),
                  ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, size: 18, color: scheme.error),
                  label: Text(l10n.delete, style: TextStyle(color: scheme.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
