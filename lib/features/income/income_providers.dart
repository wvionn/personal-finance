import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../domain/entities/income.dart';

final incomeSearchProvider = StateProvider<String>((ref) => '');

final incomeListProvider = FutureProvider<List<Income>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  final q = ref.watch(incomeSearchProvider);
  return repo.getIncomes(query: q.trim().isEmpty ? null : q.trim());
});
