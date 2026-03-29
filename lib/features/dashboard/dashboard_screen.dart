import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
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
import '../../domain/entities/quick_action.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/summary_mode.dart';
import '../../l10n/app_localizations.dart';
import '../income/income_quick_actions_customize_screen.dart';
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

  Future<void> _quickExpense(
    WidgetRef ref,
    BuildContext context,
    double amount,
    String lang, {
    String? snackMessage,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(financeRepositoryProvider);
    await repo.upsertExpense(
      Expense(
        id: _uuid.v4(),
        amount: amount,
        category: kQuickMiscCategory,
        date: DateTime.now(),
        note: l10n.savingsWithdrawalNote,
      ),
    );
    _invalidateFinance(ref);
    if (context.mounted) {
      _flash(context, snackMessage ?? l10n.recorded);
    }
  }

  Widget _dashboardFlowCard(
    BuildContext context,
    WidgetRef ref,
    DashboardSummary s,
    SavingsGoal? goal,
    AppLocalizations l10n,
    String lang,
    List<QuickAction> quickIncomes,
  ) {
    final g =
        goal ??
        SavingsGoal(
          id: 'default',
          title: l10n.savingsGoal,
          targetAmount: 5000000,
        );
    final progress = g.targetAmount <= 0
        ? 0.0
        : (s.balance / g.targetAmount).clamp(0.0, 1.0);
    final incomeActions = quickIncomes.isEmpty
        ? [
            QuickAction(
              id: 'dash-default-10',
              type: QuickActionType.income,
              label: l10n.quickAddIncome10,
              emoji: '💵',
              amount: 10000,
            ),
            QuickAction(
              id: 'dash-default-20',
              type: QuickActionType.income,
              label: l10n.quickAddIncome20,
              emoji: '🎯',
              amount: 20000,
            ),
          ]
        : quickIncomes.take(2).toList();
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
      savedFormatted: formatMoney(
        s.balance < 0 ? 0 : s.balance,
        languageCode: lang,
      ),
      targetFormatted: formatMoney(g.targetAmount, languageCode: lang),
      onTapGoal: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (ctx) => SavingsGoalEditorSheet(initial: g),
      ),
      monthlySavingsTitle: l10n.monthlySavingsTitle,
      quickIncomeTitle: l10n.quickIncomeTitle,
      onEditQuickIncome: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const IncomeQuickActionsCustomizeScreen(),
        ),
      ),
      incomeQuickActions: incomeActions,
      onFireQuickIncome: (qa) async {
        await _quickIncome(
          ref,
          context,
          qa.amount,
          snackMessage: FlowQuips.afterIncome(lang),
        );
        await ref
            .read(financeRepositoryProvider)
            .incrementQuickActionUse(qa.id);
        ref.invalidate(incomeQuickActionsProvider);
      },
      onHardcodedExpense: () => _quickExpense(
        ref,
        context,
        10000,
        lang,
        snackMessage: FlowQuips.afterExpense(
          lang,
          category: kQuickMiscCategory,
        ),
      ),
      lang: lang,
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
    final quickIncomesAsync = ref.watch(incomeQuickActionsProvider);

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
                data: (goal) => quickIncomesAsync.when(
                  data: (quickIncomes) => _dashboardFlowCard(
                    context,
                    ref,
                    s,
                    goal,
                    l10n,
                    lang,
                    quickIncomes,
                  ),
                  loading: () =>
                      _dashboardFlowCard(context, ref, s, goal, l10n, lang, []),
                  error: (error, stackTrace) =>
                      _dashboardFlowCard(context, ref, s, goal, l10n, lang, []),
                ),
                loading: () => quickIncomesAsync.when(
                  data: (quickIncomes) => _dashboardFlowCard(
                    context,
                    ref,
                    s,
                    null,
                    l10n,
                    lang,
                    quickIncomes,
                  ),
                  loading: () =>
                      _dashboardFlowCard(context, ref, s, null, l10n, lang, []),
                  error: (error, stackTrace) =>
                      _dashboardFlowCard(context, ref, s, null, l10n, lang, []),
                ),
                error: (err, st) => quickIncomesAsync.when(
                  data: (quickIncomes) => _dashboardFlowCard(
                    context,
                    ref,
                    s,
                    null,
                    l10n,
                    lang,
                    quickIncomes,
                  ),
                  loading: () =>
                      _dashboardFlowCard(context, ref, s, null, l10n, lang, []),
                  error: (error, stackTrace) =>
                      _dashboardFlowCard(context, ref, s, null, l10n, lang, []),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
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
                            .state = DateTime(
                          picked.year,
                          picked.month,
                          1,
                        );
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
                                .state =
                            picked;
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
                    '${l10n.trend} (${DateFormat.MMMM(lang == 'en' ? 'en_US' : 'id_ID').format(anchor)})',
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DailyVibeCard extends StatelessWidget {
  const _DailyVibeCard({required this.insight, required this.lang});

  final DailySpendInsight insight;
  final String lang;

  String _greetingForNow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 11) return l10n.greetingMorning;
    if (hour < 15) return l10n.greetingNoon;
    if (hour < 19) return l10n.greetingEvening;
    return l10n.greetingNight;
  }

  String _statusLeadIn(BuildContext context) {
    return AppLocalizations.of(context)!.dailyVibeLeadIn;
  }

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
            color: glow.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: glow.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greetingForNow(context),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_statusLeadIn(context)} $title',
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
