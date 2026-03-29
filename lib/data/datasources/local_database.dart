import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static const _name = 'catat_uang.db';
  static const _version = 4;

  static Future<Database> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _name);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _baseTables(db);
    await _prefsAndQuickActions(db);
    await _seedSavingsGoal(db);
    await _seedPrefs(db);
    await _seedQuickActions(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _prefsAndQuickActions(db);
      await _seedPrefs(db);
      await _seedQuickActions(db);
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE savings_goal ADD COLUMN saved_amount REAL NOT NULL DEFAULT 0.0',
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE wishlist ADD COLUMN target_amount REAL NOT NULL DEFAULT 0.0',
      );
      await db.execute(
        'ALTER TABLE wishlist ADD COLUMN saved_amount REAL NOT NULL DEFAULT 0.0',
      );
      await db.execute('ALTER TABLE wishlist ADD COLUMN item_url TEXT');
    }
  }

  static Future<void> _baseTables(Database db) async {
    await db.execute('''
      CREATE TABLE incomes (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        source TEXT NOT NULL,
        date_iso TEXT NOT NULL,
        note TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date_iso TEXT NOT NULL,
        note TEXT
      );
    ''');
    await db.execute('''
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
    await db.execute('''
      CREATE TABLE savings_goal (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        saved_amount REAL NOT NULL DEFAULT 0.0
      );
    ''');
  }

  static Future<void> _prefsAndQuickActions(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_prefs (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS quick_actions (
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
  }

  static Future<void> _seedSavingsGoal(Database db) async {
    await db.insert('savings_goal', {
      'id': 'default',
      'title': 'Target tabungan',
      'target_amount': 5000000,
      'saved_amount': 0.0,
    });
  }

  static Future<void> _seedPrefs(Database db) async {
    await db.insert('app_prefs', {
      'key': 'locale',
      'value': 'id',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> _seedQuickActions(Database db) async {
    final presets = <List<Object?>>[
      ['qa_b20', 'expense', 'Bensin', '⛽', 20000.0, 'Bahan bakar', null, 0],
      ['qa_b30', 'expense', 'Bensin', '⛽', 30000.0, 'Bahan bakar', null, 1],
      ['qa_m10', 'expense', 'Makan', '🍜', 10000.0, 'Makan', null, 2],
      ['qa_m15', 'expense', 'Makan', '🍜', 15000.0, 'Makan', null, 3],
      ['qa_m25', 'expense', 'Makan', '🍜', 25000.0, 'Makan', null, 4],
      ['qa_k10', 'expense', 'Kopi', '☕', 10000.0, 'Minuman', null, 5],
      ['qa_t10', 'expense', 'Transport', '🚗', 10000.0, 'Transport', null, 6],
      ['qa_t15', 'expense', 'Transport', '🚗', 15000.0, 'Transport', null, 7],
    ];
    for (var i = 0; i < presets.length; i++) {
      final r = presets[i];
      await db.insert('quick_actions', {
        'id': r[0],
        'action_type': r[1],
        'label': r[2],
        'emoji': r[3],
        'amount': r[4],
        'category': r[5],
        'source': r[6],
        'use_count': 0,
        'sort_order': i,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
