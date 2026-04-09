import 'package:flutter/material.dart';

import '../entities/daily_spend_insight.dart';
import '../entities/dashboard_summary.dart';
import '../entities/expense.dart';
import '../entities/income.dart';
import '../entities/quick_action.dart';
import '../entities/savings_goal.dart';
import '../entities/summary_mode.dart';
import '../entities/wishlist_item.dart';

/// Persistence contract — UI depends on this, not on SQLite.
abstract class FinanceRepository {
  Future<List<Income>> getIncomes({String? query, String? accountType});
  Future<void> upsertIncome(Income income);
  Future<void> deleteIncome(String id);

  Future<List<Expense>> getExpenses({String? query, String? accountType});
  Future<void> upsertExpense(Expense expense);
  Future<void> deleteExpense(String id);

  Future<List<WishlistItem>> getWishlist({bool includePurchased = true});
  Future<void> upsertWishlistItem(WishlistItem item);
  Future<void> deleteWishlistItem(String id);

  Future<SavingsGoal?> getSavingsGoal();
  Future<void> upsertSavingsGoal(SavingsGoal goal);

  Future<DashboardSummary> getDashboardSummary({
    required DateTime anchor,
    required SummaryMode mode,
    required String languageCode,
    DateTimeRange? customRange,
  });

  /// Expense totals grouped by category for the given month.
  Future<Map<String, double>> getExpenseTotalsByCategory(DateTime month);

  /// Raw rows for CSV export.
  Future<ExportBundle> exportAll();

  Future<String> getLocaleCode();
  Future<void> setLocaleCode(String code);

  /// [orderByUsage] true: most-used first; false: editor / drag order.
  Future<List<QuickAction>> getQuickActions({bool orderByUsage = true});
  Future<void> upsertQuickAction(QuickAction action);
  Future<void> deleteQuickAction(String id);
  Future<void> incrementQuickActionUse(String id);

  Future<DailySpendInsight> getDailySpendInsight(DateTime day);

  /// True if any income or expense exists on [day] (calendar day, local).
  Future<bool> hasAnyTransactionOn(DateTime day);
}

class ExportBundle {
  const ExportBundle({
    required this.incomes,
    required this.expenses,
    required this.wishlist,
  });

  final List<Income> incomes;
  final List<Expense> expenses;
  final List<WishlistItem> wishlist;
}
