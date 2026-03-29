import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/daily_spend_insight.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/quick_action.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/summary_mode.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<List<Income>> getIncomes({String? query}) async {
    final rows = await _db.query('incomes', orderBy: 'date_iso DESC');
    final list = rows.map(_incomeFromRow).toList();
    if (query == null || query.trim().isEmpty) return list;
    final q = query.toLowerCase();
    return list
        .where(
          (i) =>
              i.source.toLowerCase().contains(q) ||
              (i.note?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Future<void> upsertIncome(Income income) async {
    await _db.insert(
      'incomes',
      _incomeToRow(income),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteIncome(String id) async {
    await _db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Expense>> getExpenses({String? query}) async {
    final rows = await _db.query('expenses', orderBy: 'date_iso DESC');
    final list = rows.map(_expenseFromRow).toList();
    if (query == null || query.trim().isEmpty) return list;
    final q = query.toLowerCase();
    return list
        .where(
          (e) =>
              e.category.toLowerCase().contains(q) ||
              (e.note?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Future<void> upsertExpense(Expense expense) async {
    await _db.insert(
      'expenses',
      _expenseToRow(expense),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<WishlistItem>> getWishlist({bool includePurchased = true}) async {
    final rows = await _db.query(
      'wishlist',
      orderBy: 'purchased ASC, name ASC',
    );
    final items = rows.map(_wishFromRow).toList();
    if (includePurchased) return items;
    return items.where((w) => !w.purchased).toList();
  }

  @override
  Future<void> upsertWishlistItem(WishlistItem item) async {
    await _db.insert(
      'wishlist',
      _wishToRow(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteWishlistItem(String id) async {
    await _db.delete('wishlist', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<SavingsGoal?> getSavingsGoal() async {
    final rows = await _db.query('savings_goal', limit: 1);
    if (rows.isEmpty) return null;
    return _savingsFromRow(rows.first);
  }

  @override
  Future<void> upsertSavingsGoal(SavingsGoal goal) async {
    await _db.insert(
      'savings_goal',
      _savingsToRow(goal),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<DashboardSummary> getDashboardSummary({
    required DateTime anchor,
    required SummaryMode mode,
    required String languageCode,
  }) async {
    final allInc = await _sumColumn('incomes', 'amount');
    final allExp = await _sumColumn('expenses', 'amount');

    late final DateTime from;
    late final DateTime to;
    late final List<ChartPoint> chart;

    if (mode == SummaryMode.monthly) {
      from = DateTime(anchor.year, anchor.month);
      to = DateTime(anchor.year, anchor.month + 1, 0, 23, 59, 59, 999);
      chart = await _monthlyDailyBuckets(from, to, languageCode);
    } else {
      from = DateTime(anchor.year, anchor.month, anchor.day);
      to = from
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));
      chart = await _last7DayBuckets(end: from, languageCode: languageCode);
    }

    final periodInc = await _sumInRange('incomes', 'amount', from, to);
    final periodExp = await _sumInRange('expenses', 'amount', from, to);

    return DashboardSummary(
      allTimeIncome: allInc,
      allTimeExpense: allExp,
      periodIncome: periodInc,
      periodExpense: periodExp,
      chartPoints: chart,
      mode: mode,
    );
  }

  String _dayLabel(DateTime d, String languageCode) {
    final loc = languageCode == 'en' ? 'en_US' : 'id_ID';
    return DateFormat.d(loc).format(d);
  }

  Future<List<ChartPoint>> _monthlyDailyBuckets(
    DateTime from,
    DateTime to,
    String languageCode,
  ) async {
    final incomes = await _db.query('incomes');
    final expenses = await _db.query('expenses');
    final daysInMonth = to.day;
    final buckets = List.generate(daysInMonth, (i) {
      final d = DateTime(from.year, from.month, i + 1);
      return MapEntry(
        d,
        ChartPoint(label: _dayLabel(d, languageCode), income: 0, expense: 0),
      );
    });
    final map = Map<DateTime, ChartPoint>.fromEntries(buckets);

    for (final row in incomes) {
      final date = DateTime.parse(row['date_iso']! as String);
      if (date.isBefore(from) || date.isAfter(to)) continue;
      final key = DateTime(date.year, date.month, date.day);
      final existing = map[key]!;
      map[key] = ChartPoint(
        label: existing.label,
        income: existing.income + (row['amount']! as num).toDouble(),
        expense: existing.expense,
      );
    }
    for (final row in expenses) {
      final date = DateTime.parse(row['date_iso']! as String);
      if (date.isBefore(from) || date.isAfter(to)) continue;
      final key = DateTime(date.year, date.month, date.day);
      final existing = map[key]!;
      map[key] = ChartPoint(
        label: existing.label,
        income: existing.income,
        expense: existing.expense + (row['amount']! as num).toDouble(),
      );
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((e) => e.value).toList();
  }

  Future<List<ChartPoint>> _last7DayBuckets({
    required DateTime end,
    required String languageCode,
  }) async {
    final start = end.subtract(const Duration(days: 6));
    final incomes = await _db.query('incomes');
    final expenses = await _db.query('expenses');
    final map = <DateTime, ChartPoint>{};
    for (var i = 0; i < 7; i++) {
      final d = DateTime(
        start.year,
        start.month,
        start.day,
      ).add(Duration(days: i));
      map[d] = ChartPoint(
        label: _dayLabel(d, languageCode),
        income: 0,
        expense: 0,
      );
    }
    void addMoney(List<Map<String, Object?>> rows, bool isIncome) {
      for (final row in rows) {
        final date = DateTime.parse(row['date_iso']! as String);
        final key = DateTime(date.year, date.month, date.day);
        if (!map.containsKey(key)) continue;
        final existing = map[key]!;
        final v = (row['amount']! as num).toDouble();
        map[key] = ChartPoint(
          label: existing.label,
          income: existing.income + (isIncome ? v : 0),
          expense: existing.expense + (isIncome ? 0 : v),
        );
      }
    }

    addMoney(incomes, true);
    addMoney(expenses, false);
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((e) => e.value).toList();
  }

  @override
  Future<Map<String, double>> getExpenseTotalsByCategory(DateTime month) async {
    final from = DateTime(month.year, month.month);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
    final rows = await _db.query('expenses');
    final map = <String, double>{};
    for (final row in rows) {
      final date = DateTime.parse(row['date_iso']! as String);
      if (date.isBefore(from) || date.isAfter(to)) continue;
      final cat = row['category']! as String;
      map[cat] = (map[cat] ?? 0) + (row['amount']! as num).toDouble();
    }
    return map;
  }

  @override
  Future<ExportBundle> exportAll() async {
    final incomes = (await _db.query(
      'incomes',
      orderBy: 'date_iso DESC',
    )).map(_incomeFromRow).toList();
    final expenses = (await _db.query(
      'expenses',
      orderBy: 'date_iso DESC',
    )).map(_expenseFromRow).toList();
    final wishlist = (await _db.query('wishlist')).map(_wishFromRow).toList();
    return ExportBundle(
      incomes: incomes,
      expenses: expenses,
      wishlist: wishlist,
    );
  }

  Future<double> _sumColumn(String table, String column) async {
    final r = await _db.rawQuery(
      'SELECT COALESCE(SUM($column), 0) AS t FROM $table',
    );
    return (r.first['t']! as num).toDouble();
  }

  Future<double> _sumInRange(
    String table,
    String column,
    DateTime from,
    DateTime to,
  ) async {
    final r = await _db.rawQuery(
      '''
      SELECT COALESCE(SUM($column), 0) AS t FROM $table
      WHERE date_iso >= ? AND date_iso <= ?
      ''',
      [from.toIso8601String(), to.toIso8601String()],
    );
    return (r.first['t']! as num).toDouble();
  }

  Income _incomeFromRow(Map<String, Object?> row) => Income(
    id: row['id']! as String,
    amount: (row['amount']! as num).toDouble(),
    source: row['source']! as String,
    date: DateTime.parse(row['date_iso']! as String),
    note: row['note'] as String?,
  );

  Map<String, Object?> _incomeToRow(Income i) => {
    'id': i.id,
    'amount': i.amount,
    'source': i.source,
    'date_iso': i.date.toIso8601String(),
    'note': i.note,
  };

  Expense _expenseFromRow(Map<String, Object?> row) => Expense(
    id: row['id']! as String,
    amount: (row['amount']! as num).toDouble(),
    category: row['category']! as String,
    date: DateTime.parse(row['date_iso']! as String),
    note: row['note'] as String?,
  );

  Map<String, Object?> _expenseToRow(Expense e) => {
    'id': e.id,
    'amount': e.amount,
    'category': e.category,
    'date_iso': e.date.toIso8601String(),
    'note': e.note,
  };

  WishlistItem _wishFromRow(Map<String, Object?> row) => WishlistItem(
    id: row['id']! as String,
    name: row['name']! as String,
    estimatedPrice: (row['estimated_price']! as num).toDouble(),
    priority: WishlistPriority.values.firstWhere(
      (p) => p.name == row['priority'],
      orElse: () => WishlistPriority.medium,
    ),
    purchased: (row['purchased']! as int) == 1,
    purchasedAt: row['purchased_at'] != null
        ? DateTime.parse(row['purchased_at']! as String)
        : null,
    targetAmount: (row['target_amount'] as num?)?.toDouble() ?? 0.0,
    savedAmount: (row['saved_amount'] as num?)?.toDouble() ?? 0.0,
    itemUrl: row['item_url'] as String?,
  );

  Map<String, Object?> _wishToRow(WishlistItem w) => {
    'id': w.id,
    'name': w.name,
    'estimated_price': w.estimatedPrice,
    'priority': w.priority.name,
    'purchased': w.purchased ? 1 : 0,
    'purchased_at': w.purchasedAt?.toIso8601String(),
    'target_amount': w.targetAmount,
    'saved_amount': w.savedAmount,
    'item_url': w.itemUrl,
  };

  SavingsGoal _savingsFromRow(Map<String, Object?> row) => SavingsGoal(
    id: row['id']! as String,
    title: row['title']! as String,
    targetAmount: (row['target_amount']! as num).toDouble(),
    savedAmount: (row['saved_amount'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, Object?> _savingsToRow(SavingsGoal s) => {
    'id': s.id,
    'title': s.title,
    'target_amount': s.targetAmount,
    'saved_amount': s.savedAmount,
  };

  @override
  Future<String> getLocaleCode() async {
    final rows = await _db.query(
      'app_prefs',
      where: 'key = ?',
      whereArgs: const ['locale'],
    );
    if (rows.isEmpty) return 'id';
    return (rows.first['value'] as String?) ?? 'id';
  }

  @override
  Future<void> setLocaleCode(String code) async {
    await _db.insert('app_prefs', {
      'key': 'locale',
      'value': code,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<QuickAction>> getQuickActions({bool orderByUsage = true}) async {
    final orderBy = orderByUsage
        ? 'use_count DESC, sort_order ASC'
        : 'sort_order ASC';
    final rows = await _db.query('quick_actions', orderBy: orderBy);
    return rows.map(_quickFromRow).toList();
  }

  @override
  Future<void> upsertQuickAction(QuickAction action) async {
    await _db.insert(
      'quick_actions',
      _quickToRow(action),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteQuickAction(String id) async {
    await _db.delete('quick_actions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> incrementQuickActionUse(String id) async {
    await _db.rawUpdate(
      'UPDATE quick_actions SET use_count = use_count + 1 WHERE id = ?',
      [id],
    );
  }

  @override
  Future<DailySpendInsight> getDailySpendInsight(DateTime day) async {
    final monthStart = DateTime(day.year, day.month);
    final monthEnd = DateTime(day.year, day.month + 1, 0, 23, 59, 59, 999);
    final todayStart = DateTime(day.year, day.month, day.day);
    final todayEnd = todayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final rows = await _db.query('expenses');
    var monthTotal = 0.0;
    var todayTotal = 0.0;
    for (final row in rows) {
      final date = DateTime.parse(row['date_iso']! as String);
      if (date.isBefore(monthStart) || date.isAfter(monthEnd)) continue;
      final amt = (row['amount']! as num).toDouble();
      monthTotal += amt;
      if (!date.isBefore(todayStart) && !date.isAfter(todayEnd)) {
        todayTotal += amt;
      }
    }

    if (monthTotal < 1) {
      return DailySpendInsight(
        todayExpense: todayTotal,
        monthAverageDaily: 0,
        vibe: SpendVibe.normal,
        hasEnoughData: false,
      );
    }

    final dayOfMonth = day.day;
    final avgDaily = monthTotal / dayOfMonth;
    if (avgDaily < 0.01) {
      return DailySpendInsight(
        todayExpense: todayTotal,
        monthAverageDaily: avgDaily,
        vibe: SpendVibe.normal,
        hasEnoughData: false,
      );
    }

    final ratio = todayTotal / avgDaily;
    final vibe = ratio < 0.75
        ? SpendVibe.hemat
        : ratio <= 1.25
        ? SpendVibe.normal
        : SpendVibe.boros;

    return DailySpendInsight(
      todayExpense: todayTotal,
      monthAverageDaily: avgDaily,
      vibe: vibe,
      hasEnoughData: true,
    );
  }

  @override
  Future<bool> hasAnyTransactionOn(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    final from = start.toIso8601String();
    final to = end.toIso8601String();
    final i = await _db.rawQuery(
      'SELECT 1 FROM incomes WHERE date_iso >= ? AND date_iso <= ? LIMIT 1',
      [from, to],
    );
    if (i.isNotEmpty) return true;
    final e = await _db.rawQuery(
      'SELECT 1 FROM expenses WHERE date_iso >= ? AND date_iso <= ? LIMIT 1',
      [from, to],
    );
    return e.isNotEmpty;
  }

  QuickAction _quickFromRow(Map<String, Object?> row) => QuickAction(
    id: row['id']! as String,
    type: (row['action_type']! as String) == 'income'
        ? QuickActionType.income
        : QuickActionType.expense,
    label: row['label']! as String,
    emoji: row['emoji']! as String,
    amount: (row['amount']! as num).toDouble(),
    category: row['category'] as String?,
    source: row['source'] as String?,
    useCount: (row['use_count']! as num).toInt(),
    sortOrder: (row['sort_order']! as num).toInt(),
  );

  Map<String, Object?> _quickToRow(QuickAction a) => {
    'id': a.id,
    'action_type': a.type == QuickActionType.income ? 'income' : 'expense',
    'label': a.label,
    'emoji': a.emoji,
    'amount': a.amount,
    'category': a.category,
    'source': a.source,
    'use_count': a.useCount,
    'sort_order': a.sortOrder,
  };
}
