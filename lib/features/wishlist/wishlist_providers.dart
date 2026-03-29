import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../domain/entities/wishlist_item.dart';

final wishlistProvider = FutureProvider<List<WishlistItem>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getWishlist(includePurchased: true);
});

final averageMonthlySavingsProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  final incomes = await repo.getIncomes();
  final expenses = await repo.getExpenses();

  if (incomes.isEmpty && expenses.isEmpty) return 0.0;

  DateTime? earliestDate;
  double totalSaving = 0;

  for (final inc in incomes) {
    totalSaving += inc.amount;
    if (earliestDate == null || inc.date.isBefore(earliestDate)) {
      earliestDate = inc.date;
    }
  }

  for (final exp in expenses) {
    totalSaving -= exp.amount;
    if (earliestDate == null || exp.date.isBefore(earliestDate)) {
      earliestDate = exp.date;
    }
  }

  if (earliestDate == null) return 0.0;

  final now = DateTime.now();
  var monthsCount =
      (now.year - earliestDate.year) * 12 + now.month - earliestDate.month + 1;

  if (monthsCount <= 0) monthsCount = 1;

  final avg = totalSaving / monthsCount;
  return avg > 0 ? avg : 0.0;
});
