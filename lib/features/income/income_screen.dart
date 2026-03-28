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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final listAsync = ref.watch(incomeListProvider);
    final query = ref.watch(incomeSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.income),
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
                      return SectionCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
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
                          onTap: () => _openForm(context, inc),
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
        onPressed: () => _openForm(context, null),
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
