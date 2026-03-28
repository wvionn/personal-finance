import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/csv_export_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/notifications/idle_transaction_nudge.dart';
import '../../core/widgets/quick_pill_button.dart';
import '../../core/widgets/section_card.dart';
import '../../domain/entities/daily_spend_insight.dart' show DailySpendInsight, SpendVibe;
import '../../domain/entities/expense.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/summary_mode.dart';
import '../../l10n/app_localizations.dart';
import '../income/income_providers.dart';
import '../settings/settings_screen.dart';
import '../expense/expense_providers.dart';
import 'dashboard_providers.dart';
import 'widgets/monthly_report_sheet.dart';
import 'widgets/savings_goal_editor_sheet.dart';
import 'widgets/trend_bar_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _uuid = Uuid();

  void _invalidateFinance(WidgetRef ref) {
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(savingsGoalProvider);
    ref.invalidate(dailyInsightProvider);
    ref.invalidate(incomeListProvider);
    ref.invalidate(expenseListProvider);
  }

  Future<void> _quickIncome(
    WidgetRef ref,
    BuildContext context,
    double amount,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(financeRepositoryProvider);
    await repo.upsertIncome(
      Income(
        id: _uuid.v4(),
        amount: amount,
        source: l10n.incomeSourceQuick,
        date: DateTime.now(),
        note: l10n.noteQuickDash,
      ),
    );
    _invalidateFinance(ref);
    if (context.mounted) _flash(context);
  }

  Future<void> _quickExpense(
    WidgetRef ref,
    BuildContext context,
    double amount,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(financeRepositoryProvider);
    await repo.upsertExpense(
      Expense(
        id: _uuid.v4(),
        amount: amount,
        category: kQuickMiscCategory,
        date: DateTime.now(),
        note: l10n.noteQuickDash,
      ),
    );
    _invalidateFinance(ref);
    if (context.mounted) _flash(context);
  }

  void _flash(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.recorded),
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(dashboardSummaryProvider, (previous, next) {
      next.whenData((_) {
        Future.microtask(() => IdleTransactionNudge.maybeAfterDashboardLoad(ref));
      });
    });

    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final mode = ref.watch(summaryModeProvider);
    final anchor = ref.watch(selectedDashboardAnchorProvider);
    final goalAsync = ref.watch(savingsGoalProvider);
    final insightAsync = ref.watch(dailyInsightProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const SettingsScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.monthlyReport,
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              showDragHandle: true,
              builder: (ctx) => const MonthlyReportSheet(),
            ),
          ),
          IconButton(
            tooltip: l10n.exportCsv,
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () async {
              final repo = ref.read(financeRepositoryProvider);
              final bundle = await repo.exportAll();
              final csv = CsvExportService.buildCsv(bundle);
              if (!context.mounted) return;
              await CsvExportService.shareCsv(csv);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(savingsGoalProvider);
          ref.invalidate(dailyInsightProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            insightAsync.when(
              data: (ins) => _DailyVibeCard(insight: ins, lang: lang),
              loading: () => const SizedBox.shrink(),
              error: (_, stackTrace) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            summaryAsync.when(
              data: (s) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.balance,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMoney(s.balance, languageCode: lang),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          color: s.balance >= 0
                              ? AppTheme.positiveMoney
                              : AppTheme.spendStress,
                        ),
                  ),
                  Text(
                    l10n.balanceSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.quickAdd,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                QuickPillButton(
                  label: l10n.quickAddIncome10,
                  subtitle: formatMoney(10000, languageCode: lang),
                  borderColor: AppTheme.mediumBrown,
                  labelColor: AppTheme.darkBrown,
                  onTap: () => _quickIncome(ref, context, 10000),
                ),
                QuickPillButton(
                  label: l10n.quickAddIncome20,
                  subtitle: formatMoney(20000, languageCode: lang),
                  borderColor: AppTheme.mediumBrown,
                  labelColor: AppTheme.darkBrown,
                  onTap: () => _quickIncome(ref, context, 20000),
                ),
                QuickPillButton(
                  label: l10n.quickAddExpense10,
                  subtitle: formatMoney(10000, languageCode: lang),
                  borderColor: AppTheme.spendStress,
                  labelColor: AppTheme.darkBrown,
                  onTap: () => _quickExpense(ref, context, 10000),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.monthly),
                  selected: mode == SummaryMode.monthly,
                  selectedColor: AppTheme.beige,
                  onSelected: (_) {
                    ref.read(summaryModeProvider.notifier).state =
                        SummaryMode.monthly;
                    ref.invalidate(dashboardSummaryProvider);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.daily),
                  selected: mode == SummaryMode.daily,
                  selectedColor: AppTheme.beige,
                  onSelected: (_) {
                    ref.read(summaryModeProvider.notifier).state =
                        SummaryMode.daily;
                    ref.invalidate(dashboardSummaryProvider);
                  },
                ),
                const Spacer(),
                if (mode == SummaryMode.monthly)
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(anchor.year, anchor.month),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        ref
                            .read(selectedDashboardAnchorProvider.notifier)
                            .state = DateTime(picked.year, picked.month, 1);
                        ref.invalidate(dashboardSummaryProvider);
                      }
                    },
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(formatMonthYear(
                      DateTime(anchor.year, anchor.month),
                      languageCode: lang,
                    )),
                  )
                else
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: anchor,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        ref
                            .read(selectedDashboardAnchorProvider.notifier)
                            .state = picked;
                        ref.invalidate(dashboardSummaryProvider);
                      }
                    },
                    icon: const Icon(Icons.today, size: 18),
                    label: Text(formatShortDate(anchor, languageCode: lang)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            summaryAsync.when(
              data: (s) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SectionCard(
                          child: _miniStat(
                            context,
                            l10n.periodIncome,
                            formatMoney(s.periodIncome, languageCode: lang),
                            Icons.trending_up,
                            AppTheme.mediumBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SectionCard(
                          child: _miniStat(
                            context,
                            l10n.periodExpense,
                            formatMoney(s.periodExpense, languageCode: lang),
                            Icons.trending_down,
                            AppTheme.darkBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.trend,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  SectionCard(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                    child: SizedBox(
                      height: 220,
                      child: s.chartPoints.isEmpty
                          ? Center(child: Text(l10n.noChartData))
                          : TrendBarChart(
                              points: s.chartPoints,
                              languageCode: lang,
                              incomeLabel: l10n.trendIncome,
                              expenseLabel: l10n.trendExpense,
                            ),
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, stackTrace) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            goalAsync.when(
              data: (goal) {
                final g = goal ??
                    const SavingsGoal(
                      id: 'default',
                      title: 'Target tabungan',
                      targetAmount: 5000000,
                    );
                final balance = summaryAsync.value?.balance ?? 0;
                final progress = g.targetAmount <= 0
                    ? 0.0
                    : (balance / g.targetAmount).clamp(0.0, 1.0);
                return SectionCard(
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    builder: (ctx) => SavingsGoalEditorSheet(initial: g),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.savingsGoal,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        g.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${formatMoney(balance, languageCode: lang)} / ${formatMoney(g.targetAmount, languageCode: lang)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TweenAnimationBuilder<double>(
                        key: ValueKey<double>(progress),
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 850),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 12,
                              backgroundColor: scheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.mediumBrown,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, st) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color tint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: tint),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _DailyVibeCard extends StatelessWidget {
  const _DailyVibeCard({required this.insight, required this.lang});

  final DailySpendInsight insight;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    late final String title;
    late final String hint;
    late final Color glow;

    if (!insight.hasEnoughData) {
      title = l10n.dailyStatus;
      hint = l10n.statusNoData;
      glow = AppTheme.mediumBrown;
    } else {
      switch (insight.vibe) {
        case SpendVibe.hemat:
          title = l10n.statusHemat;
          hint = l10n.statusHematHint;
          glow = AppTheme.darkBrown;
        case SpendVibe.normal:
          title = l10n.statusNormal;
          hint = l10n.statusNormalHint;
          glow = AppTheme.mediumBrown;
        case SpendVibe.boros:
          title = l10n.statusBoros;
          hint = l10n.statusBorosHint;
          glow = AppTheme.spendStress;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.cream,
        border: Border.all(color: glow.withValues(alpha: 0.55), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyStatus,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: glow,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
          if (insight.hasEnoughData)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.todaySpend,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  formatMoney(insight.todayExpense, languageCode: lang),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
