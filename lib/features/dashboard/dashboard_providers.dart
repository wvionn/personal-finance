import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../core/providers/locale_provider.dart';
import '../../domain/entities/daily_spend_insight.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/summary_mode.dart';

/// Selected calendar anchor (day for daily mode, any day in month for monthly).
final selectedDashboardAnchorProvider = StateProvider<DateTime>((ref) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
});

final summaryModeProvider =
    StateProvider<SummaryMode>((ref) => SummaryMode.monthly);

final dashboardSummaryProvider =
    FutureProvider<DashboardSummary>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  final anchor = ref.watch(selectedDashboardAnchorProvider);
  final mode = ref.watch(summaryModeProvider);
  final lang = ref.watch(localeProvider).languageCode;
  return repo.getDashboardSummary(
    anchor: anchor,
    mode: mode,
    languageCode: lang,
  );
});

final dailyInsightProvider = FutureProvider<DailySpendInsight>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getDailySpendInsight(DateTime.now());
});

final savingsGoalProvider = FutureProvider((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getSavingsGoal();
});

/// Month used for the simple "monthly report" breakdown sheet.
final reportMonthProvider = StateProvider<DateTime>((ref) {
  final n = DateTime.now();
  return DateTime(n.year, n.month);
});
