import 'dart:io';

import 'package:sqflite/sqflite.dart';

class DatabaseBackupService {
  static const _requiredTables = <String>{
    'incomes',
    'expenses',
    'wishlist',
    'savings_goal',
  };

  static Future<void> exportToPath({
    required Database db,
    required String outputPath,
  }) async {
    final target = File(outputPath);
    await target.parent.create(recursive: true);
    if (await target.exists()) {
      await target.delete();
    }

    final incomes = await db.query('incomes');
    final expenses = await db.query('expenses');
    final wishlist = await db.query('wishlist');
    final savingsGoal = await db.query('savings_goal');
    final appPrefs = await _safeQuery(db, 'app_prefs');
    final quickActions = await _safeQuery(db, 'quick_actions');

    final backupDb = await openDatabase(
      outputPath,
      version: 1,
      onCreate: (b, v) async {
        await b.execute('''
          CREATE TABLE incomes (
            id TEXT PRIMARY KEY,
            amount REAL NOT NULL,
            source TEXT NOT NULL,
            date_iso TEXT NOT NULL,
            note TEXT
          );
        ''');
        await b.execute('''
          CREATE TABLE expenses (
            id TEXT PRIMARY KEY,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date_iso TEXT NOT NULL,
            note TEXT
          );
        ''');
        await b.execute('''
          CREATE TABLE wishlist (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            estimated_price REAL NOT NULL,
            priority TEXT NOT NULL,
            purchased INTEGER NOT NULL DEFAULT 0,
            purchased_at TEXT,
            target_amount REAL NOT NULL DEFAULT 0.0,
            saved_amount REAL NOT NULL DEFAULT 0.0,
            item_url TEXT
          );
        ''');
        await b.execute('''
          CREATE TABLE savings_goal (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            target_amount REAL NOT NULL,
            saved_amount REAL NOT NULL DEFAULT 0.0
          );
        ''');
        await b.execute('''
          CREATE TABLE app_prefs (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          );
        ''');
        await b.execute('''
          CREATE TABLE quick_actions (
            id TEXT PRIMARY KEY,
            action_type TEXT NOT NULL,
            label TEXT NOT NULL,
            emoji TEXT NOT NULL DEFAULT '',
            amount REAL NOT NULL,
            category TEXT,
            source TEXT,
            use_count INTEGER NOT NULL DEFAULT 0,
            sort_order INTEGER NOT NULL DEFAULT 0
          );
        ''');
      },
    );

    try {
      await backupDb.transaction((txn) async {
        for (final row in incomes) {
          await txn.insert(
            'incomes',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (final row in expenses) {
          await txn.insert(
            'expenses',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (final row in wishlist) {
          await txn.insert(
            'wishlist',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (final row in savingsGoal) {
          await txn.insert(
            'savings_goal',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (final row in appPrefs) {
          await txn.insert(
            'app_prefs',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (final row in quickActions) {
          await txn.insert(
            'quick_actions',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } finally {
      await backupDb.close();
    }
  }

  static Future<void> importFromPath({
    required Database db,
    required String inputPath,
  }) async {
    final sourceDb = await openDatabase(
      inputPath,
      readOnly: true,
      singleInstance: false,
    );
    try {
      await _validateSource(sourceDb);

      final incomes = await sourceDb.query('incomes');
      final expenses = await sourceDb.query('expenses');
      final wishlist = await sourceDb.query('wishlist');
      final savingsGoal = await sourceDb.query('savings_goal');
      final appPrefs = await _safeQuery(sourceDb, 'app_prefs');
      final quickActions = await _safeQuery(sourceDb, 'quick_actions');

      await db.transaction((txn) async {
        await txn.delete('incomes');
        await txn.delete('expenses');
        await txn.delete('wishlist');
        await txn.delete('savings_goal');
        await txn.delete('app_prefs');
        await txn.delete('quick_actions');

        for (final row in incomes) {
          await txn.insert('incomes', {
            'id': row['id'],
            'amount': row['amount'],
            'source': row['source'],
            'date_iso': row['date_iso'],
            'note': row['note'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        for (final row in expenses) {
          await txn.insert('expenses', {
            'id': row['id'],
            'amount': row['amount'],
            'category': row['category'],
            'date_iso': row['date_iso'],
            'note': row['note'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        for (final row in wishlist) {
          await txn.insert('wishlist', {
            'id': row['id'],
            'name': row['name'],
            'estimated_price': row['estimated_price'],
            'priority': row['priority'],
            'purchased': row['purchased'] ?? 0,
            'purchased_at': row['purchased_at'],
            'target_amount': (row['target_amount'] as num?)?.toDouble() ?? 0.0,
            'saved_amount': (row['saved_amount'] as num?)?.toDouble() ?? 0.0,
            'item_url': row['item_url'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        for (final row in savingsGoal) {
          await txn.insert('savings_goal', {
            'id': row['id'],
            'title': row['title'],
            'target_amount': row['target_amount'],
            'saved_amount': (row['saved_amount'] as num?)?.toDouble() ?? 0.0,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        for (final row in appPrefs) {
          await txn.insert('app_prefs', {
            'key': row['key'],
            'value': row['value'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        for (final row in quickActions) {
          await txn.insert('quick_actions', {
            'id': row['id'],
            'action_type': row['action_type'],
            'label': row['label'],
            'emoji': row['emoji'] ?? '',
            'amount': row['amount'],
            'category': row['category'],
            'source': row['source'],
            'use_count': row['use_count'] ?? 0,
            'sort_order': row['sort_order'] ?? 0,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    } finally {
      await sourceDb.close();
    }
  }

  static Future<List<Map<String, Object?>>> _safeQuery(
    Database db,
    String table,
  ) async {
    final exists = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    if (exists.isEmpty) return <Map<String, Object?>>[];
    return db.query(table);
  }

  static Future<void> _validateSource(Database db) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    final names = rows.map((e) => e['name']).whereType<String>().toSet();

    final missing = _requiredTables.where((t) => !names.contains(t)).toList();
    if (missing.isNotEmpty) {
      throw StateError(
        'File backup tidak valid. Tabel hilang: ${missing.join(', ')}',
      );
    }

    final counts = await Future.wait([
      db.rawQuery('SELECT COUNT(*) AS c FROM incomes'),
      db.rawQuery('SELECT COUNT(*) AS c FROM expenses'),
      db.rawQuery('SELECT COUNT(*) AS c FROM wishlist'),
    ]);
    final total = counts
        .map((r) => (r.first['c'] as num?)?.toInt() ?? 0)
        .fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      throw StateError(
        'Backup kosong (0 data). Pilih file backup lain yang berisi data.',
      );
    }
  }
}
