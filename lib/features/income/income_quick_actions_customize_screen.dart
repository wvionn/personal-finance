import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/localized_labels.dart';
import '../../domain/entities/quick_action.dart';
import '../../l10n/app_localizations.dart';
import 'income_providers.dart';

class IncomeQuickActionsCustomizeScreen extends ConsumerWidget {
  const IncomeQuickActionsCustomizeScreen({super.key});

  static const _uuid = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final async = ref.watch(incomeQuickActionsCustomizeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customizeQuick)),
      body: async.when(
        data: (items) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  l10n.maxQuickActionsNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(l10n.noChartData),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final list = List<QuickAction>.from(items);
                          final moved = list.removeAt(oldIndex);
                          list.insert(newIndex, moved);
                          final repo = ref.read(financeRepositoryProvider);
                          for (var i = 0; i < list.length; i++) {
                            await repo.upsertQuickAction(
                              list[i].copyWith(sortOrder: i),
                            );
                          }
                          ref.invalidate(incomeQuickActionsCustomizeProvider);
                          ref.invalidate(incomeQuickActionsProvider);
                        },
                        itemBuilder: (context, index) {
                          final q = items[index];
                          return Card(
                            key: ValueKey(q.id),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Text(
                                q.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                              title: Text(q.label),
                              subtitle: Text(
                                '${incomeSourceLabel(q.source ?? '', lang)} · ${formatMoney(q.amount, languageCode: lang)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _edit(context, ref, q),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error,
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(context, ref, q),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: async.when(
        data: (items) {
          final canAdd = items.length < kMaxQuickActions;
          return FloatingActionButton(
            onPressed: canAdd
                ? () => _edit(context, ref, null)
                : () => _showQuickActionLimitReached(context),
            child: Icon(canAdd ? Icons.add : Icons.block_outlined),
          );
        },
        loading: () => null,
        error: (error, stackTrace) => null,
      ),
    );
  }

  void _showQuickActionLimitReached(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.quickActionsLimitReached)));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    QuickAction action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('${action.label}?'),
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
      await ref.read(financeRepositoryProvider).deleteQuickAction(action.id);
      ref.invalidate(incomeQuickActionsCustomizeProvider);
      ref.invalidate(incomeQuickActionsProvider);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    QuickAction? existing,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final emojiCtrl = TextEditingController(text: existing?.emoji ?? '✨');
    final amountCtrl = TextEditingController(
      text: existing?.amount.toString() ?? '10000',
    );
    var source = existing?.source ?? kIncomeSources.first;
    if (!kIncomeSources.contains(source)) {
      source = kIncomeSources.last;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSt) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      existing == null
                          ? l10n.addQuickTitle
                          : l10n.editQuickTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: emojiCtrl,
                      decoration: InputDecoration(labelText: l10n.emojiField),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: labelCtrl,
                      decoration: InputDecoration(labelText: l10n.labelField),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountCtrl,
                      decoration: InputDecoration(labelText: l10n.amountField),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: source,
                      items: kIncomeSources
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                incomeSourceLabel(
                                  s,
                                  Localizations.localeOf(context).languageCode,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setSt(() => source = v ?? source),
                      decoration: InputDecoration(labelText: l10n.sourceLabel),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () async {
                        final amt = double.tryParse(amountCtrl.text.trim());
                        if (amt == null || amt <= 0 || labelCtrl.text.isEmpty) {
                          return;
                        }
                        final repo = ref.read(financeRepositoryProvider);
                        final all = await repo.getQuickActions(
                          orderByUsage: false,
                        );
                        final incomes = all
                            .where((a) => a.type == QuickActionType.income)
                            .toList();
                        if (existing == null && incomes.length >= kMaxQuickActions) {
                          if (ctx.mounted) {
                            _showQuickActionLimitReached(ctx);
                          }
                          return;
                        }
                        final maxSo = incomes.isEmpty
                            ? -1
                            : incomes.map((e) => e.sortOrder).reduce(math.max);
                        final nextOrder = existing?.sortOrder ?? maxSo + 1;
                        final qa = QuickAction(
                          id: existing?.id ?? _uuid.v4(),
                          type: QuickActionType.income,
                          label: labelCtrl.text.trim(),
                          emoji: emojiCtrl.text.trim().isEmpty
                              ? '✨'
                              : emojiCtrl.text.trim(),
                          amount: amt,
                          source: source,
                          useCount: existing?.useCount ?? 0,
                          sortOrder: nextOrder,
                        );
                        await repo.upsertQuickAction(qa);
                        ref.invalidate(incomeQuickActionsCustomizeProvider);
                        ref.invalidate(incomeQuickActionsProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
