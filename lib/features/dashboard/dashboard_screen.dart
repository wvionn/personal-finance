import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/core_providers.dart';
import '../../core/services/csv_export_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/notifications/idle_transaction_nudge.dart';
import '../../core/widgets/section_card.dart';
import '../../domain/entities/daily_spend_insight.dart'
    show DailySpendInsight, SpendVibe;
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/summary_mode.dart';
import '../../l10n/app_localizations.dart';
import '../income/income_providers.dart';
import '../settings/settings_screen.dart';
import '../expense/expense_providers.dart';
import 'dashboard_providers.dart';
import 'widgets/dashboard_flow_card.dart';
import 'widgets/flow_quips.dart';
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
    double amount, {
    String? snackMessage,
  }) async {
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
    if (context.mounted) {
      _flash(context, snackMessage ?? l10n.recorded);
    }
  }

  void _flash(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: message.length > 24 ? 2400 : 900),
      ),
    );
  }

  static const _defaultSavingsGoal = SavingsGoal(
    id: 'default',
    title: 'Target tabungan',
    targetAmount: 5000000,
  );

  Widget _dashboardFlowCard(
    BuildContext context,
    WidgetRef ref,
    DashboardSummary s,
    SavingsGoal? goal,
    AppLocalizations l10n,
    String lang,
  ) {
    final g = goal ?? _defaultSavingsGoal;
    final progress = g.targetAmount <= 0
        ? 0.0
        : (s.balance / g.targetAmount).clamp(0.0, 1.0);
    return DashboardFlowCard(
      balanceLabel: l10n.balance,
      balanceFormatted: formatMoney(s.balance, languageCode: lang),
      balanceSubtitle: l10n.balanceSubtitle,
      balanceColor: s.balance >= 0
          ? AppTheme.positiveMoney
          : AppTheme.spendStress,
      goalTitle: '${l10n.savingsGoal} · ${g.title}',
      goalProgressLabel: '${(progress * 100).round()}%',
      progress: progress,
      onTapGoal: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (ctx) => SavingsGoalEditorSheet(initial: g),
      ),
      monthlySavingsTitle:
          lang == 'id' ? 'Tabungan bulanan' : 'Monthly savings',
      quickIncomeTitle: lang == 'id' ? 'Pemasukan cepat' : 'Quick income',
      incomeQuickLabel: l10n.quickAddIncome10,
      incomeQuickLabel2: l10n.quickAddIncome20,
      incomeQuickIcon: Icons.add_card_rounded,
      incomeQuickIcon2: Icons.savings_rounded,
      incomeQuickSubtitle2: formatMoney(20000, languageCode: lang),
      onIncome10k: () => _quickIncome(
        ref,
        context,
        10000,
        snackMessage: FlowQuips.afterIncome(lang),
      ),
      onIncome20k: () => _quickIncome(
        ref,
        context,
        20000,
        snackMessage: FlowQuips.afterIncome(lang),
      ),
      quickAmountSubtitle: formatMoney(10000, languageCode: lang),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(dashboardSummaryProvider, (previous, next) {
      next.whenData((_) {
        Future.microtask(
          () => IdleTransactionNudge.maybeAfterDashboardLoad(ref),
        );
      });
    });

    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final mode = ref.watch(summaryModeProvider);
    final anchor = ref.watch(selectedDashboardAnchorProvider);
    final goalAsync = ref.watch(savingsGoalProvider);
    final insightAsync = ref.watch(dailyInsightProvider);

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            insightAsync.when(
              data: (ins) => _DailyVibeCard(insight: ins, lang: lang),
              loading: () => const SizedBox.shrink(),
              error: (_, stackTrace) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            summaryAsync.when(
              data: (s) => goalAsync.when(
                data: (goal) =>
                    _dashboardFlowCard(context, ref, s, goal, l10n, lang),
                loading: () =>
                    _dashboardFlowCard(context, ref, s, null, l10n, lang),
                error: (err, st) =>
                    _dashboardFlowCard(context, ref, s, null, l10n, lang),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SegmentedButton<SummaryMode>(
                  showSelectedIcon: true,
                  segments: [
                    ButtonSegment(
                      value: SummaryMode.monthly,
                      label: Text(l10n.monthly),
                    ),
                    ButtonSegment(
                      value: SummaryMode.daily,
                      label: Text(l10n.daily),
                    ),
                  ],
                  selected: {mode},
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.elevated;
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return AppTheme.textMain;
                    }),
                    side: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const BorderSide(color: AppTheme.elevated);
                      }
                      return const BorderSide(color: AppTheme.textMain);
                    }),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  onSelectionChanged: (selected) {
                    final next = selected.first;
                    if (next == mode) return;
                    ref.read(summaryModeProvider.notifier).state = next;
                    ref.invalidate(dashboardSummaryProvider);
                  },
                ),
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
                    label: Text(
                      formatMonthYear(
                        DateTime(anchor.year, anchor.month),
                        languageCode: lang,
                      ),
                    ),
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
                    label: Text(
                      formatShortDate(anchor, languageCode: lang),
                    ),
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
                            AppTheme.chartIncome,
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
                            AppTheme.chartExpense,
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: tint,
            letterSpacing: -0.5,
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
      glow = AppTheme.neonAmber;
    } else {
      switch (insight.vibe) {
        case SpendVibe.hemat:
          title = l10n.statusHemat;
          hint = l10n.statusHematHint;
          glow = AppTheme.neonAmber;
        case SpendVibe.normal:
          title = l10n.statusNormal;
          hint = l10n.statusNormalHint;
          glow = AppTheme.textMain;
        case SpendVibe.boros:
          title = l10n.statusBoros;
          hint = l10n.statusBorosHint;
          glow = AppTheme.spendStress;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppTheme.panel,
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: glow.withValues(alpha: 0.35),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 0),
          ),
        ],
        border: Border.all(
          color: glow.withValues(alpha: 0.6),
          width: 1.5,
        ),
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
                    shadows: [
                      Shadow(
                        color: glow.withValues(alpha: 0.6),
                        blurRadius: 12,
                      ),
                    ],
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
