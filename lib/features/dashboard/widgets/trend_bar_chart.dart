import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/dashboard_summary.dart';

/// Fixed axis + tooltips — avoids stray fractional title values from fl_chart.
class TrendBarChart extends StatelessWidget {
  const TrendBarChart({
    super.key,
    required this.points,
    required this.languageCode,
    required this.incomeLabel,
    required this.expenseLabel,
  });

  final List<ChartPoint> points;
  final String languageCode;
  final String incomeLabel;
  final String expenseLabel;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    double maxVal = 0;
    for (final p in points) {
      maxVal = math.max(maxVal, math.max(p.income, p.expense));
    }
    final maxY = maxVal <= 0 ? 100000.0 : maxVal * 1.12;

    final interval = points.length > 12 ? (points.length / 5).ceil() : 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        groupsSpace: 10,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) =>
                const Color(0xFF3B3028).withValues(alpha: 0.96),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final i = group.x.toInt();
              if (i < 0 || i >= points.length) return null;
              final p = points[i];
              final isIncome = rodIndex == 0;
              final label = isIncome ? incomeLabel : expenseLabel;
              final val = isIncome ? p.income : p.expense;
              return BarTooltipItem(
                '$label\n${formatMoney(val, languageCode: languageCode)}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.25,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if ((value - i).abs() > 0.001) {
                  return const SizedBox.shrink();
                }
                if (i < 0 || i >= points.length) {
                  return const SizedBox.shrink();
                }
                if (i % interval != 0 && i != points.length - 1) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    points[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 25000,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: points[i].income,
                  width: 5,
                  color: AppTheme.chartIncome,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                ),
                BarChartRodData(
                  fromY: 0,
                  toY: points[i].expense,
                  width: 5,
                  color: AppTheme.chartExpense,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
