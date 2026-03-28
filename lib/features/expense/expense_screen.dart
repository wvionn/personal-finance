import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/core_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/quick_pill_button.dart';
import '../../core/widgets/section_card.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/quick_action.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_providers.dart';
import 'ai_expense_sheet.dart';
import 'expense_form_sheet.dart';
import 'expense_providers.dart';
import 'quick_actions_customize_screen.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  late final TextEditingController _searchCtrl;
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: ref.read(expenseSearchProvider))
      ..addListener(() {
        ref.read(expenseSearchProvider.notifier).state = _searchCtrl.text;
      });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fireQuick(QuickAction qa) async {
    if (qa.category == null) return;
    final repo = ref.read(financeRepositoryProvider);
    await repo.upsertExpense(
      Expense(
        id: _uuid.v4(),
        amount: qa.amount,
        category: qa.category!,
        date: DateTime.now(),
        note: '${qa.emoji} ${qa.label}',
      ),
    );
    await repo.incrementQuickActionUse(qa.id);
    ref.invalidate(quickActionsProvider);
    ref.invalidate(expenseListProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(dailyInsightProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.recorded),
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final listAsync = ref.watch(expenseListProvider);
    final query = ref.watch(expenseSearchProvider);
    final quickAsync = ref.watch(quickActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenseTitle),
        actions: [
          IconButton(
            tooltip: l10n.aiInput,
            icon: const Icon(Icons.auto_fix_high_outlined),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              showDragHandle: true,
              builder: (ctx) => const AiExpenseSheet(),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.searchExpense,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  l10n.smartQuickAdd,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          const QuickActionsCustomizeScreen(),
                    ),
                  ).then((_) {
                    ref.invalidate(quickActionsProvider);
                    ref.invalidate(quickActionsCustomizeProvider);
                  }),
                  icon: const Icon(Icons.tune, size: 18),
                  label: Text(l10n.customizeQuick),
                ),
              ],
            ),
          ),
          quickAsync.when(
            data: (actions) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final qa in actions)
                    QuickPillButton(
                      compact: true,
                      label: '${qa.emoji} ${qa.label}',
                      subtitle:
                          '− ${formatMoney(qa.amount, languageCode: lang)}',
                      borderColor: AppTheme.quickExpenseAccent,
                      labelColor: AppTheme.darkBrown,
                      onTap: () => _fireQuick(qa),
                    ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('$e'),
            ),
          ),
          Expanded(
            child: listAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long,
                    title: query.isEmpty
                        ? l10n.noExpensesYet
                        : l10n.noSearchMatches,
                    subtitle: query.isEmpty ? l10n.tapToLog : null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(expenseListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final exp = items[i];
                      return SectionCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(exp.category),
                          subtitle: Text(
                            '${formatShortDate(exp.date, languageCode: lang)}'
                            '${exp.note != null ? ' · ${exp.note}' : ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatMoney(exp.amount, languageCode: lang),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppTheme.spendStress,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (action) async {
                                  if (action == 'delete') {
                                    await ref
                                        .read(financeRepositoryProvider)
                                        .deleteExpense(exp.id);
                                    ref.invalidate(expenseListProvider);
                                    ref.invalidate(dashboardSummaryProvider);
                                    ref.invalidate(dailyInsightProvider);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(l10n.delete),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => _openForm(context, exp),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.manualEntry),
      ),
    );
  }

  void _openForm(BuildContext context, Expense? existing) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => ExpenseFormSheet(existing: existing),
    ).then((_) {
      ref.invalidate(expenseListProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(dailyInsightProvider);
    });
  }
}