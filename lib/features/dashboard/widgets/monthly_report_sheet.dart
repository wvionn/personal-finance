import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../dashboard_providers.dart';

/// Simple category breakdown for expenses in a selected month.
class MonthlyReportSheet extends ConsumerWidget {
  const MonthlyReportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final month = ref.watch(reportMonthProvider);
    final asyncCats = ref.watch(_reportCategoriesProvider(month));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  l10n.monthlyReport,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: month,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      helpText: l10n.monthlyReport,
                    );
                    if (picked != null) {
                      ref.read(reportMonthProvider.notifier).state =
                          DateTime(picked.year, picked.month);
                    }
                  },
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(formatMonthYear(month, languageCode: lang)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            asyncCats.when(
              data: (map) {
                if (map.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.reportEmptyMonth),
                  );
                }
                final total = map.values.fold<double>(0, (a, b) => a + b);
                final entries = map.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final e in entries)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(e.key),
                        trailing:
                            Text(formatMoney(e.value, languageCode: lang)),
                        subtitle: Text(
                          l10n.percentOfSpend(
                            ((e.value / total) * 100).toStringAsFixed(0),
                          ),
                        ),
                      ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.totalLabel),
                      titleTextStyle: Theme.of(context).textTheme.titleMedium,
                      trailing:
                          Text(formatMoney(total, languageCode: lang)),
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('$e'),
            ),
          ],
        ),
      ),
    );
  }
}

final _reportCategoriesProvider =
    FutureProvider.family<Map<String, double>, DateTime>((ref, month) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getExpenseTotalsByCategory(month);
});
