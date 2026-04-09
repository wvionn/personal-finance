import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/quick_action.dart';

final expenseSearchProvider = StateProvider<String>((ref) => '');
final expenseAccountTypeFilterProvider = StateProvider<String>(
  (ref) => kAccountTypeAll,
);

final expenseListProvider = FutureProvider<List<Expense>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  final q = ref.watch(expenseSearchProvider);
  final accountType = ref.watch(expenseAccountTypeFilterProvider);
  return repo.getExpenses(
    query: q.trim().isEmpty ? null : q.trim(),
    accountType: accountType == kAccountTypeAll ? null : accountType,
  );
});

final quickActionsProvider = FutureProvider<List<QuickAction>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  final all = await repo.getQuickActions(orderByUsage: true);
  return all.where((a) => a.type == QuickActionType.expense).toList();
});

final quickActionsCustomizeProvider = FutureProvider<List<QuickAction>>((
  ref,
) async {
  final repo = ref.watch(financeRepositoryProvider);
  final all = await repo.getQuickActions(orderByUsage: false);
  return all.where((a) => a.type == QuickActionType.expense).toList();
});
