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
  final Set<String> _selectedExpenseIds = <String>{};
  DateTime? _singleDate;
  DateTimeRange? _dateRange;

  bool get _isSelecting => _selectedExpenseIds.isNotEmpty;
  bool get _hasDateFilter => _singleDate != null || _dateRange != null;

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

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedExpenseIds.contains(id)) {
        _selectedExpenseIds.remove(id);
      } else {
        _selectedExpenseIds.add(id);
      }
    });
  }

  void _clearSelection() {
    if (_selectedExpenseIds.isEmpty) return;
    setState(_selectedExpenseIds.clear);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _matchesDateFilter(DateTime value) {
    if (_singleDate != null) {
      return _isSameDay(value, _singleDate!);
    }
    if (_dateRange != null) {
      final start = DateTime(
        _dateRange!.start.year,
        _dateRange!.start.month,
        _dateRange!.start.day,
      );
      final endExclusive = DateTime(
        _dateRange!.end.year,
        _dateRange!.end.month,
        _dateRange!.end.day,
      ).add(const Duration(days: 1));
      return !value.isBefore(start) && value.isBefore(endExclusive);
    }
    return true;
  }

  String _dateFilterLabel(String lang) {
    if (_singleDate != null) {
      final date = formatShortDate(_singleDate!, languageCode: lang);
      return lang == 'id' ? 'Tanggal: $date' : 'Date: $date';
    }
    if (_dateRange != null) {
      final start = formatShortDate(_dateRange!.start, languageCode: lang);
      final end = formatShortDate(_dateRange!.end, languageCode: lang);
      return lang == 'id' ? 'Rentang: $start - $end' : 'Range: $start - $end';
    }
    return '';
  }

  Future<void> _openDateFilter() async {
    if (_isSelecting) return;
    final lang = Localizations.localeOf(context).languageCode;
    final action = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: Text(
                lang == 'id' ? 'Pilih satu tanggal' : 'Pick one date',
              ),
              onTap: () => Navigator.pop(ctx, 'single'),
            ),
            ListTile(
              leading: const Icon(Icons.date_range_outlined),
              title: Text(
                lang == 'id' ? 'Pilih rentang tanggal' : 'Pick date range',
              ),
              onTap: () => Navigator.pop(ctx, 'range'),
            ),
            ListTile(
              leading: const Icon(Icons.filter_alt_off_outlined),
              title: Text(
                lang == 'id' ? 'Reset filter tanggal' : 'Clear date filter',
              ),
              onTap: () => Navigator.pop(ctx, 'clear'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == 'single') {
      final picked = await showDatePicker(
        context: context,
        initialDate: _singleDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (!mounted || picked == null) return;
      setState(() {
        _singleDate = picked;
        _dateRange = null;
      });
      _clearSelection();
      return;
    }

    if (action == 'range') {
      final now = DateTime.now();
      final initial =
          _dateRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
      final picked = await showDateRangePicker(
        context: context,
        initialDateRange: initial,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (!mounted || picked == null) return;
      setState(() {
        _dateRange = picked;
        _singleDate = null;
      });
      _clearSelection();
      return;
    }

    if (action == 'clear') {
      setState(() {
        _singleDate = null;
        _dateRange = null;
      });
      _clearSelection();
    }
  }

  Future<void> _deleteSelectedExpenses() async {
    if (_selectedExpenseIds.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final count = _selectedExpenseIds.length;
    final content = lang == 'id'
        ? 'Hapus $count pengeluaran terpilih?'
        : 'Delete $count selected expenses?';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(content),
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
    if (ok != true || !mounted) return;

    final repo = ref.read(financeRepositoryProvider);
    for (final id in _selectedExpenseIds) {
      await repo.deleteExpense(id);
    }

    _clearSelection();
    ref.invalidate(expenseListProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(dailyInsightProvider);
    if (!mounted) return;
    final msg = lang == 'id'
        ? '$count pengeluaran dihapus'
        : '$count expenses deleted';
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.recorded),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final listAsync = ref.watch(expenseListProvider);
    final query = ref.watch(expenseSearchProvider);
    final quickAsync = ref.watch(quickActionsProvider);
    final selectedLabel = lang == 'id'
        ? '${_selectedExpenseIds.length} dipilih'
        : '${_selectedExpenseIds.length} selected';
    final dateFilterLabel = _dateFilterLabel(lang);

    return Scaffold(
      appBar: AppBar(
        leading: _isSelecting
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        title: Text(_isSelecting ? selectedLabel : l10n.expenseTitle),
        actions: _isSelecting
            ? [
                IconButton(
                  tooltip: l10n.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteSelectedExpenses,
                ),
              ]
            : [
                IconButton(
                  tooltip: lang == 'id' ? 'Filter tanggal' : 'Filter by date',
                  icon: Icon(
                    _hasDateFilter
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined,
                  ),
                  onPressed: _openDateFilter,
                ),
                // Temporarily disabled AI input / smart quick add
                // IconButton(
                //   tooltip: l10n.aiInput,
                //   icon: const Icon(Icons.auto_fix_high_outlined),
                //   onPressed: () => showModalBottomSheet<void>(
                //     context: context,
                //     isScrollControlled: true,
                //     useSafeArea: true,
                //     showDragHandle: true,
                //     builder: (ctx) => const AiExpenseSheet(),
                //   ),
                // ),
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
          if (_hasDateFilter)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dateFilterLabel,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _singleDate = null;
                        _dateRange = null;
                      });
                      _clearSelection();
                    },
                    child: Text(lang == 'id' ? 'Reset' : 'Clear'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  l10n.smartQuickAdd,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              const QuickActionsCustomizeScreen(),
                        ),
                      )
                      .then((_) {
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
                      labelColor: AppTheme.textMain,
                      onTap: () => _fireQuick(qa),
                    ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) =>
                Padding(padding: const EdgeInsets.all(16), child: Text('$e')),
          ),
          Expanded(
            child: listAsync.when(
              data: (items) {
                final filtered = items
                    .where((exp) => _matchesDateFilter(exp.date))
                    .toList();
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long,
                    title: _hasDateFilter
                        ? (lang == 'id'
                              ? 'Tidak ada pengeluaran pada tanggal ini'
                              : 'No expenses in this date filter')
                        : query.isEmpty
                        ? l10n.noExpensesYet
                        : l10n.noSearchMatches,
                    subtitle: query.isEmpty ? l10n.tapToLog : null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(expenseListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final exp = filtered[i];
                      final selected = _selectedExpenseIds.contains(exp.id);
                      return SectionCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          selected: selected,
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppTheme.spendStress,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (_isSelecting)
                                Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: selected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                )
                              else
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
                          onTap: () {
                            if (_isSelecting) {
                              _toggleSelection(exp.id);
                              return;
                            }
                            _openForm(context, exp);
                          },
                          onLongPress: () => _toggleSelection(exp.id),
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
        onPressed: _isSelecting ? null : () => _openForm(context, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.add),
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
