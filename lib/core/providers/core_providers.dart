import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/repositories/finance_repository_impl.dart';
import '../../domain/repositories/finance_repository.dart';

/// Open database once; overridden in [main] after async init.
final databaseProvider = Provider<Database>((ref) {
  throw StateError('databaseProvider not initialized');
});

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FinanceRepositoryImpl(db);
});
