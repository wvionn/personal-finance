import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/localized_labels.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_card.dart';
import '../../domain/entities/expense.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_providers.dart';
import 'expense_form_sheet.dart';
import 'expense_providers.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  late final TextEditingController _searchCtrl;
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

  String _dateFilterLabel(AppLocalizations l10n, String lang) {
    if (_singleDate != null) {
      final date = formatShortDate(_singleDate!, languageCode: lang);
      return l10n.dateFilterDateLabel(date);
    }
    if (_dateRange != null) {
      final start = formatShortDate(_dateRange!.start, languageCode: lang);
      final end = formatShortDate(_dateRange!.end, languageCode: lang);
      return l10n.dateFilterRangeLabel(start, end);
    }
    return '';
  }

  Future<void> _openDateFilter() async {
    if (_isSelecting) return;
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.pickOneDate),
              onTap: () => Navigator.pop(ctx, 'single'),
            ),
            ListTile(
              leading: const Icon(Icons.date_range_outlined),
              title: Text(l10n.pickDateRange),
              onTap: () => Navigator.pop(ctx, 'range'),
            ),
            ListTile(
              leading: const Icon(Icons.filter_alt_off_outlined),
              title: Text(l10n.clearDateFilter),
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
    final count = _selectedExpenseIds.length;
    final content = l10n.deleteSelectedExpensesConfirm(count);
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

    if (!mounted) return;
    final msg = l10n.deleteSelectedExpensesDone(count);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(content: Text(msg)));

    _clearSelection();
    ref.invalidate(expenseListProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(dailyInsightProvider);
  }

  Future<void> _refreshExpensePage() async {
    _clearSelection();
    ref.invalidate(expenseListProvider);
    ref.invalidate(quickActionsProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(savingsGoalProvider);
    ref.invalidate(dailyInsightProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final listAsync = ref.watch(expenseListProvider);
    final query = ref.watch(expenseSearchProvider);
    final accountTypeFilter = ref.watch(expenseAccountTypeFilterProvider);
    final selectedLabel = l10n.selectedCount(_selectedExpenseIds.length);
    final dateFilterLabel = _dateFilterLabel(l10n, lang);

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
                  tooltip: l10n.dateFilter,
                  icon: Icon(
                    _hasDateFilter
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined,
                  ),
                  onPressed: _openDateFilter,
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment<String>(
                    value: kAccountTypeAll,
                    label: Text(accountTypeLabel(kAccountTypeAll, lang)),
                  ),
                  ButtonSegment<String>(
                    value: kAccountTypeCash,
                    label: Text(accountTypeLabel(kAccountTypeCash, lang)),
                  ),
                  ButtonSegment<String>(
                    value: kAccountTypeBank,
                    label: Text(accountTypeLabel(kAccountTypeBank, lang)),
                  ),
                ],
                selected: {accountTypeFilter},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  ref.read(expenseAccountTypeFilterProvider.notifier).state =
                      selection.first;
                  _clearSelection();
                },
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
                    child: Text(l10n.reset),
                  ),
                ],
              ),
            ),
          Expanded(
            child: listAsync.when(
              data: (items) {
                final filtered = items
                    .where((exp) => _matchesDateFilter(exp.date))
                    .toList();
                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshExpensePage,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                      children: [
                        const SizedBox(height: 64),
                        EmptyState(
                          icon: Icons.receipt_long,
                          title: _hasDateFilter
                              ? l10n.noExpensesInDateFilter
                              : query.isEmpty
                              ? l10n.noExpensesYet
                              : l10n.noSearchMatches,
                          subtitle: query.isEmpty ? l10n.tapToLog : null,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refreshExpensePage,
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
                          title: Text(expenseCategoryLabel(exp.category, lang)),
                          subtitle: Text(
                            '${formatShortDate(exp.date, languageCode: lang)}'
                            ' · ${accountTypeLabel(exp.accountType, lang)}'
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
