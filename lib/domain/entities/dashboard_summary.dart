import 'summary_mode.dart';

/// Aggregates for dashboard: all-time balance plus period breakdown and chart data.
class DashboardSummary {
  const DashboardSummary({
    required this.allTimeIncome,
    required this.allTimeExpense,
    required this.allTimeCashIncome,
    required this.allTimeCashExpense,
    required this.allTimeBankIncome,
    required this.allTimeBankExpense,
    required this.periodIncome,
    required this.periodExpense,
    required this.chartPoints,
    required this.mode,
  });

  final double allTimeIncome;
  final double allTimeExpense;
  final double allTimeCashIncome;
  final double allTimeCashExpense;
  final double allTimeBankIncome;
  final double allTimeBankExpense;

  /// Income within the selected day or month window.
  final double periodIncome;
  final double periodExpense;

  final List<ChartPoint> chartPoints;
  final SummaryMode mode;

  double get balance => allTimeIncome - allTimeExpense;
  double get cashBalance => allTimeCashIncome - allTimeCashExpense;
  double get bankBalance => allTimeBankIncome - allTimeBankExpense;
}

class ChartPoint {
  const ChartPoint({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;
}
