import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
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

  bool get _isSelecting => _selectedIncomeIds.isNotEmpty;

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

  Future<void> _deleteSelectedIncomes(BuildContext context) async {
    if (_selectedIncomeIds.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final count = _selectedIncomeIds.length;
    final content = lang == 'id'
        ? 'Hapus $count pemasukan terpilih?'
        : 'Delete $count selected incomes?';
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

    _clearSelection();
    ref.invalidate(incomeListProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(dailyInsightProvider);
    if (!context.mounted) return;
    final msg =
        lang == 'id' ? '$count pemasukan dihapus' : '$count incomes deleted';
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final listAsync = ref.watch(incomeListProvider);
    final query = ref.watch(incomeSearchProvider);
    final selectedLabel = lang == 'id'
        ? '${_selectedIncomeIds.length} dipilih'
        : '${_selectedIncomeIds.length} selected';

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
                  onPressed: () => _deleteSelectedIncomes(context),
                ),
              ]
            : null,
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
          Expanded(
            child: listAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.trending_up,
                    title: query.isEmpty
                        ? l10n.noIncomeYet
                        : l10n.noIncomeMatches,
                    subtitle:
                        query.isEmpty ? l10n.tapToAddIncome : null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(incomeListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final inc = items[i];
                      final selected = _selectedIncomeIds.contains(inc.id);
                      return SectionCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          selected: selected,
                          title: Text(inc.source),
                          subtitle: Text(
                            '${formatShortDate(inc.date, languageCode: lang)}'
                            '${inc.note != null ? ' · ${inc.note}' : ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatMoney(inc.amount, languageCode: lang),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
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
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
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
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
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
