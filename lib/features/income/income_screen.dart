import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/localized_labels.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_card.dart';
import '../../domain/entities/income.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_providers.dart';
import 'income_form_sheet.dart';
import 'income_providers.dart';

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  late final TextEditingController _searchCtrl;
  final Set<String> _selectedIncomeIds = <String>{};
  DateTime? _singleDate;
  DateTimeRange? _dateRange;

  bool get _isSelecting => _selectedIncomeIds.isNotEmpty;
  bool get _hasDateFilter => _singleDate != null || _dateRange != null;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: ref.read(incomeSearchProvider))
      ..addListener(() {
        ref.read(incomeSearchProvider.notifier).state = _searchCtrl.text;
      });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIncomeIds.contains(id)) {
        _selectedIncomeIds.remove(id);
      } else {
        _selectedIncomeIds.add(id);
      }
    });
  }

  void _clearSelection() {
    if (_selectedIncomeIds.isEmpty) return;
    setState(_selectedIncomeIds.clear);
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

  Future<void> _deleteSelectedIncomes() async {
    if (_selectedIncomeIds.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final count = _selectedIncomeIds.length;
    final content = l10n.deleteSelectedIncomesConfirm(count);
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
    for (final id in _selectedIncomeIds) {
      await repo.deleteIncome(id);
    }

    if (!mounted) return;
    final msg = l10n.deleteSelectedIncomesDone(count);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(content: Text(msg)));

    _clearSelection();
    ref.invalidate(incomeListProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(dailyInsightProvider);
  }

  Future<void> _refreshIncomePage() async {
    _clearSelection();
    ref.invalidate(incomeListProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(savingsGoalProvider);
    ref.invalidate(dailyInsightProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final listAsync = ref.watch(incomeListProvider);
    final query = ref.watch(incomeSearchProvider);
    final accountTypeFilter = ref.watch(incomeAccountTypeFilterProvider);
    final selectedLabel = l10n.selectedCount(_selectedIncomeIds.length);
    final dateFilterLabel = _dateFilterLabel(l10n, lang);

    return Scaffold(
      appBar: AppBar(
        leading: _isSelecting
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        title: Text(_isSelecting ? selectedLabel : l10n.income),
        actions: _isSelecting
            ? [
                IconButton(
                  tooltip: l10n.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteSelectedIncomes,
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.searchIncome,
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
                  ref.read(incomeAccountTypeFilterProvider.notifier).state =
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
                    .where((inc) => _matchesDateFilter(inc.date))
                    .toList();
                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshIncomePage,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        const SizedBox(height: 64),
                        EmptyState(
                          icon: Icons.trending_up,
                          title: _hasDateFilter
                              ? l10n.noIncomesInDateFilter
                              : query.isEmpty
                              ? l10n.noIncomeYet
                              : l10n.noIncomeMatches,
                          subtitle: query.isEmpty ? l10n.tapToAddIncome : null,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refreshIncomePage,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final inc = filtered[i];
                      final selected = _selectedIncomeIds.contains(inc.id);
                      return SectionCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          selected: selected,
                          title: Text(incomeSourceLabel(inc.source, lang)),
                          subtitle: Text(
                            '${formatShortDate(inc.date, languageCode: lang)}'
                            ' · ${accountTypeLabel(inc.accountType, lang)}'
                            '${inc.note != null ? ' · ${inc.note}' : ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatMoney(inc.amount, languageCode: lang),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppTheme.positiveMoney,
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
                                          .deleteIncome(inc.id);
                                      ref.invalidate(incomeListProvider);
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
                              _toggleSelection(inc.id);
                              return;
                            }
                            _openForm(context, inc);
                          },
                          onLongPress: () => _toggleSelection(inc.id),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _isSelecting ? null : () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openForm(BuildContext context, Income? existing) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => IncomeFormSheet(existing: existing),
    ).then((_) {
      ref.invalidate(incomeListProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(dailyInsightProvider);
    });
  }
}
