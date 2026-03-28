enum SpendVibe { hemat, normal, boros }

/// Compares today's spending vs average daily burn in the current month.
class DailySpendInsight {
  const DailySpendInsight({
    required this.todayExpense,
    required this.monthAverageDaily,
    required this.vibe,
    required this.hasEnoughData,
  });

  final double todayExpense;
  final double monthAverageDaily;
  final SpendVibe vibe;
  final bool hasEnoughData;
}
