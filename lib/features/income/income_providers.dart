import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/quick_action.dart';

final incomeSearchProvider = StateProvider<String>((ref) => '');
final incomeAccountTypeFilterProvider = StateProvider<String>(
  (ref) => kAccountTypeAll,
);

final incomeListProvider = FutureProvider<List<Income>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  final q = ref.watch(incomeSearchProvider);
  final accountType = ref.watch(incomeAccountTypeFilterProvider);
  return repo.getIncomes(
    query: q.trim().isEmpty ? null : q.trim(),
    accountType: accountType == kAccountTypeAll ? null : accountType,
  );
});

/// Income quick actions sorted by usage frequency — shown on the dashboard.
final incomeQuickActionsProvider = FutureProvider<List<QuickAction>>((
  ref,
) async {
  final repo = ref.watch(financeRepositoryProvider);
  final all = await repo.getQuickActions(orderByUsage: true);
  return all.where((a) => a.type == QuickActionType.income).toList();
});

/// Income quick actions sorted by sort order — used in the customize screen.
final incomeQuickActionsCustomizeProvider = FutureProvider<List<QuickAction>>((
  ref,
) async {
  final repo = ref.watch(financeRepositoryProvider);
  final all = await repo.getQuickActions(orderByUsage: false);
  return all.where((a) => a.type == QuickActionType.income).toList();
});
