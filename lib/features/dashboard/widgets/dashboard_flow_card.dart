import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/quick_pill_button.dart';
import '../../../core/widgets/section_card.dart';
import '../../../domain/entities/quick_action.dart';

/// Home flow block with summary and functional quick actions.
class DashboardFlowCard extends StatelessWidget {
  const DashboardFlowCard({
    super.key,
    required this.balanceLabel,
    required this.balanceFormatted,
    required this.balanceSubtitle,
    required this.balanceColor,
    required this.goalTitle,
    required this.goalProgressLabel,
    required this.progress,
    required this.savedFormatted,
    required this.targetFormatted,
    required this.onTapGoal,
    required this.monthlySavingsTitle,
    required this.quickIncomeTitle,
    required this.onEditQuickIncome,
    required this.incomeQuickActions,
    required this.onFireQuickIncome,
    required this.onHardcodedExpense, // To keep the old -10k behavior
    required this.lang,
  });

  final String balanceLabel;
  final String balanceFormatted;
  final String balanceSubtitle;
  final Color balanceColor;
  final String goalTitle;
  final String goalProgressLabel;
  final double progress;
  final String savedFormatted;
  final String targetFormatted;
  final VoidCallback onTapGoal;
  final String monthlySavingsTitle;
  final String quickIncomeTitle;
  final VoidCallback onEditQuickIncome;
  final List<QuickAction> incomeQuickActions;
  final Function(QuickAction) onFireQuickIncome;
  final VoidCallback onHardcodedExpense;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeroSection(context),
        const SizedBox(height: 24),
        _buildQuickSectionTitle(context, quickIncomeTitle),
        const SizedBox(height: 12),
        _buildIncomeGrid(),
        const SizedBox(height: 24),
        _buildSavingsSection(context),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          balanceLabel,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.textMuted,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          balanceFormatted,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            color: balanceColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          balanceSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.textMain,
              ),
        ),
        IconButton(
          onPressed: onEditQuickIncome,
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(Icons.edit, size: 16, color: AppTheme.textMain),
        ),
      ],
    );
  }

  Widget _buildIncomeGrid() {
    return Row(
      children: [
        for (final qa in incomeQuickActions) ...[
          Expanded(
            child: QuickPillButton(
              icon: null,
              label: '${qa.emoji} ${qa.label}',
              subtitle: '+ ${formatMoney(qa.amount, languageCode: lang)}',
              compact: true,
              borderColor: AppTheme.borderHighlight,
              labelColor: AppTheme.textMain,
              onTap: () => onFireQuickIncome(qa),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: QuickPillButton(
            icon: Icons.add_card_rounded,
            label: "−10 rb",
            subtitle: "Cepat",
            compact: true,
            borderColor: AppTheme.borderHighlight,
            labelColor: AppTheme.spendStress,
            onTap: onHardcodedExpense, // Ideally this maps to an expense func, just mirroring UI
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsSection(BuildContext context) {
    return SectionCard(
      onTap: onTapGoal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthlySavingsTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textMain,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Icon(
                Icons.edit,
                size: 16,
                color: AppTheme.textMain,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            goalTitle.split('·').last.trim(), // Showing just "My savings goal" cleanly
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMain,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            "$savedFormatted / $targetFormatted",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            key: ValueKey<double>(progress),
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonAmber.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 12, // Ticker bar height
                    backgroundColor: AppTheme.panel, // Deep dark integration
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.neonAmber,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
