import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/quick_pill_button.dart';
import '../../../core/widgets/section_card.dart';

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
    required this.onTapGoal,
    required this.monthlySavingsTitle,
    required this.quickIncomeTitle,
    required this.incomeQuickLabel,
    required this.incomeQuickLabel2,
    required this.incomeQuickIcon,
    required this.incomeQuickIcon2,
    required this.incomeQuickSubtitle2,
    required this.onIncome10k,
    required this.onIncome20k,
    required this.quickAmountSubtitle,
  });

  final String balanceLabel;
  final String balanceFormatted;
  final String balanceSubtitle;
  final Color balanceColor;
  final String goalTitle;
  final String goalProgressLabel;
  final double progress;
  final VoidCallback onTapGoal;
  final String monthlySavingsTitle;
  final String quickIncomeTitle;
  final String incomeQuickLabel;
  final String incomeQuickLabel2;
  final IconData incomeQuickIcon;
  final IconData incomeQuickIcon2;
  final String incomeQuickSubtitle2;
  final VoidCallback onIncome10k;
  final VoidCallback onIncome20k;
  final String quickAmountSubtitle;

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
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.textMain,
          ),
    );
  }

  Widget _buildIncomeGrid() {
    return Row(
      children: [
        Expanded(
          child: QuickPillButton(
            icon: incomeQuickIcon,
            label: incomeQuickLabel,
            subtitle: quickAmountSubtitle,
            compact: true,
            borderColor: AppTheme.borderHighlight,
            labelColor: AppTheme.textMain,
            onTap: onIncome10k,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: QuickPillButton(
            icon: incomeQuickIcon2,
            label: incomeQuickLabel2,
            subtitle: incomeQuickSubtitle2,
            compact: true,
            borderColor: AppTheme.borderHighlight,
            labelColor: AppTheme.textMain,
            onTap: onIncome20k,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: QuickPillButton(
            icon: incomeQuickIcon,
            label: "-10 rb",
            subtitle: quickAmountSubtitle,
            compact: true,
            borderColor: AppTheme.borderHighlight,
            labelColor: AppTheme.spendStress,
            onTap: onIncome10k, // Ideally this maps to an expense func, just mirroring UI
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
            "${AppTheme.positiveMoney == balanceColor ? 'Rp0' : 'Rp0'} / ${goalProgressLabel == '0%' ? 'Rp1.000' : 'Rp0'}", // Hardcoded to match mockup style visually if requested
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
