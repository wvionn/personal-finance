import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/localized_labels.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_card.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_providers.dart';
import '../expense/expense_providers.dart';
import 'wishlist_form_sheet.dart';
import 'wishlist_providers.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  static const _uuid = Uuid();
  WishlistPriority? _selectedPriority;
  bool? _sortPriceDesc;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final listAsync = ref.watch(wishlistProvider);
    final avgSavingsAsync = ref.watch(averageMonthlySavingsProvider);
    final avgSavings = avgSavingsAsync.valueOrNull ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wishlist)),
      body: listAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.card_giftcard,
              title: l10n.wishlistEmptyTitle,
              subtitle: l10n.wishlistEmptySubtitle,
            );
          }
          var open = items.where((w) => !w.purchased).toList();
          
          if (_selectedPriority != null) {
            open = open.where((w) => w.priority == _selectedPriority).toList();
          }

          if (_sortPriceDesc != null) {
            open.sort((a, b) => _sortPriceDesc! ? b.estimatedPrice.compareTo(a.estimatedPrice) : a.estimatedPrice.compareTo(b.estimatedPrice));
          } else {
            open.sort(_priorityCompare);
          }

          final done = items.where((w) => w.purchased).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(wishlistProvider);
              ref.invalidate(averageMonthlySavingsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (open.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.sort),
                      tooltip: 'Sort & Filter',
                      onSelected: (val) {
                        setState(() {
                          if (val == 'price_desc') _sortPriceDesc = true;
                          if (val == 'price_asc') _sortPriceDesc = false;
                          if (val == 'default_sort') _sortPriceDesc = null;
                          if (val == 'high') _selectedPriority = WishlistPriority.high;
                          if (val == 'medium') _selectedPriority = WishlistPriority.medium;
                          if (val == 'low') _selectedPriority = WishlistPriority.low;
                          if (val == 'all') _selectedPriority = null;
                        });
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'price_desc', child: Text('Harga Tertinggi')),
                        const PopupMenuItem(value: 'price_asc', child: Text('Harga Terendah')),
                        const PopupMenuItem(value: 'default_sort', child: Text('Prioritas (Default)')),
                        const PopupMenuDivider(),
                        const PopupMenuItem(value: 'high', child: Text('High')),
                        const PopupMenuItem(value: 'medium', child: Text('Medium')),
                        const PopupMenuItem(value: 'low', child: Text('Low')),
                        const PopupMenuItem(value: 'all', child: Text('All')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...open.map(
                    (w) => _WishTile(
                      lang: lang,
                      item: w,
                      avgSavings: avgSavings,
                      onEdit: () => _openForm(context, ref, w),
                      onPurchased: () => _markPurchasedFlow(context, ref, w),
                      onDelete: () => _delete(context, ref, w),
                    ),
                  ),
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const SizedBox(height: 8),
                  ...done.map(
                    (w) => _WishTile(
                      lang: lang,
                      item: w,
                      avgSavings: 0,
                      onEdit: () => _openForm(context, ref, w),
                      onPurchased: null,
                      onDelete: () => _delete(context, ref, w),
                    ),
                  ),
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
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteWishlistItemTitle),
        content: Text(l10n.deleteWishlistItemBody(w.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context)!;
    final addExpense = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.markPurchasedTitle),
        content: Text(l10n.markPurchasedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.markOnly),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.addExpense),
          ),
        ],
      ),
    );
    if (addExpense == null || !context.mounted) return;

    var amount = w.estimatedPrice;
    var category = kExpenseCategories.firstWhere(
      (c) => c.toLowerCase() == 'belanja',
      orElse: () => kExpenseCategories.first,
    );
    final date = DateTime.now();
    final note = '${l10n.wishlistExpenseNotePrefix}: ${w.name}';

    if (addExpense) {
      final result = await showDialog<_WishlistExpenseDraft>(
        context: context,
        builder: (_) => _WishlistExpenseDialog(
          initialAmount: w.estimatedPrice,
          initialCategory: category,
        ),
      );
      if (result == null || !context.mounted) return;
      amount = result.amount;
      category = result.category;
    }

    final repo = ref.read(financeRepositoryProvider);
    await repo.upsertWishlistItem(
      w.copyWith(purchased: true, purchasedAt: DateTime.now()),
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
    required this.avgSavings,
    required this.onEdit,
    required this.onDelete,
    this.onPurchased,
  });

  final String lang;
  final WishlistItem item;
  final double avgSavings;
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

    final progress = item.targetAmount > 0
        ? (item.savedAmount / item.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    String getEstimation() {
      if (item.targetAmount <= 0) return '';
      final remaining = item.targetAmount - item.savedAmount;
      if (remaining <= 0) {
        return '${l10n.fundsReady}\u{1F389}';
      }

      final monthly = avgSavings > 0
          ? avgSavings
          : 500000.0; // fallback asumsi 500rb
      final monthsNeeded = (remaining / monthly).ceil();
      if (monthsNeeded > 120) {
        return '${l10n.overTenYears}\u{1F622}';
      }

      final estimatedDate = DateTime.now().add(
        Duration(days: 30 * monthsNeeded),
      );
      final locale = lang == 'en' ? 'en_US' : 'id_ID';
      final monthStr = DateFormat.MMM(locale).format(estimatedDate);
      if (lang == 'id') {
        return '${l10n.achievableBy(monthStr, estimatedDate.year.toString())} '
            '(jika tertabung ${formatMoney(monthly, languageCode: lang)}/bln)';
      }
      return l10n.achievableBy(monthStr, estimatedDate.year.toString());
    }

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
                Chip(
                  label: Text(
                    item.priority.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: chipColor,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatMoney(item.estimatedPrice, languageCode: lang),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),

            if (!item.purchased) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: scheme.surfaceContainerHighest,
                color: scheme.primary,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.savedAmountLabel(
                      formatMoney(item.savedAmount, languageCode: lang),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: scheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        getEstimation(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (item.purchased && item.purchasedAt != null)
              Text(
                '${l10n.purchased} ${item.purchasedAt!.toLocal().toString().split(' ').first}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(l10n.edit),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                if (!item.purchased && onPurchased != null)
                  FilledButton.icon(
                    onPressed: onPurchased,
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(l10n.purchased),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                if (item.itemUrl != null && item.itemUrl!.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(item.itemUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                    label: Text(l10n.buyLink),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: scheme.error,
                  ),
                  label: Text(
                    l10n.delete,
                    style: TextStyle(color: scheme.error),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistExpenseDraft {
  const _WishlistExpenseDraft({required this.amount, required this.category});

  final double amount;
  final String category;
}

class _WishlistExpenseDialog extends StatefulWidget {
  const _WishlistExpenseDialog({
    required this.initialAmount,
    required this.initialCategory,
  });

  final double initialAmount;
  final String initialCategory;

  @override
  State<_WishlistExpenseDialog> createState() => _WishlistExpenseDialogState();
}

class _WishlistExpenseDialogState extends State<_WishlistExpenseDialog> {
  late final TextEditingController _amountCtrl;
  late String _category;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.initialAmount.toString());
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    return AlertDialog(
      title: Text(l10n.expenseDetails),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountCtrl,
              decoration: InputDecoration(labelText: l10n.amountLabel),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) {
                  return l10n.validatorAmountPositive;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _category,
              items: kExpenseCategories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(expenseCategoryLabel(c, lang)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _category = v);
              },
              decoration: InputDecoration(labelText: l10n.categoryField),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              _WishlistExpenseDraft(
                amount: double.parse(_amountCtrl.text.trim()),
                category: _category,
              ),
            );
          },
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
