import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/quick_pill_button.dart';
import '../../../core/widgets/section_card.dart';

/// Home “flow” block: saldo, savings progress, one-tap +10k / −10k (Makan).
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
    required this.incomeQuickLabel,
    required this.onIncome10k,
    required this.expenseMakanLabel,
    required this.quickAmountSubtitle,
    required this.onExpenseMakan10k,
  });

  final String balanceLabel;
  final String balanceFormatted;
  final String balanceSubtitle;
  final Color balanceColor;
  final String goalTitle;
  final String goalProgressLabel;
  final double progress;
  final VoidCallback onTapGoal;
  final String incomeQuickLabel;
  final VoidCallback onIncome10k;
  final String expenseMakanLabel;
  final String quickAmountSubtitle;
  final VoidCallback onExpenseMakan10k;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          balanceLabel,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          balanceFormatted,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: balanceColor,
              ),
        ),
        Text(
          balanceSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 20),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTapGoal,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goalTitle,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      Text(
                        goalProgressLabel,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.mediumBrown,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: QuickPillButton(
                label: incomeQuickLabel,
                subtitle: quickAmountSubtitle,
                compact: true,
                borderColor: AppTheme.mediumBrown,
                labelColor: AppTheme.darkBrown,
                onTap: onIncome10k,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickPillButton(
                label: expenseMakanLabel,
                subtitle: quickAmountSubtitle,
                compact: true,
                borderColor: AppTheme.spendStress,
                labelColor: AppTheme.darkBrown,
                onTap: onExpenseMakan10k,
              ),
            ),
          ],
        ),
      ],
    );

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: body,
    );
  }
}
