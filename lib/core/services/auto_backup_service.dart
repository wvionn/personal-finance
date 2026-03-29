import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'database_backup_service.dart';

enum AutoBackupFrequency { off, daily, weekly }

class AutoBackupService {
  static const _prefFrequency = 'auto_backup_frequency';
  static const _prefLastRunIso = 'auto_backup_last_run_iso';

  static Future<AutoBackupFrequency> getFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefFrequency) ?? 'off';
    return switch (raw) {
      'daily' => AutoBackupFrequency.daily,
      'weekly' => AutoBackupFrequency.weekly,
      _ => AutoBackupFrequency.off,
    };
  }

  static Future<void> setFrequency(AutoBackupFrequency frequency) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = switch (frequency) {
      AutoBackupFrequency.off => 'off',
      AutoBackupFrequency.daily => 'daily',
      AutoBackupFrequency.weekly => 'weekly',
    };
    await prefs.setString(_prefFrequency, raw);
  }

  static Future<String?> maybeRun(Database db) async {
    final frequency = await getFrequency();
    if (frequency == AutoBackupFrequency.off) return null;

    final prefs = await SharedPreferences.getInstance();
    final lastRunIso = prefs.getString(_prefLastRunIso);
    final now = DateTime.now();
    if (lastRunIso != null) {
      final lastRun = DateTime.tryParse(lastRunIso);
      if (lastRun != null && !_isDue(frequency, lastRun, now)) {
        return null;
      }
    }

    final path = await runNow(db);
    await prefs.setString(_prefLastRunIso, now.toIso8601String());
    return path;
  }

  static Future<String> runNow(Database db) async {
    final now = DateTime.now();
    final docs = await getApplicationDocumentsDirectory();
    final backupDir = p.join(docs.path, 'backups');
    final outputPath = p.join(
      backupDir,
      'backup_${_dateStamp(now)}_${_timeStamp(now)}.db',
    );
    await DatabaseBackupService.exportToPath(db: db, outputPath: outputPath);
    return outputPath;
  }

  static bool _isDue(
    AutoBackupFrequency frequency,
    DateTime last,
    DateTime now,
  ) {
    final diff = now.difference(last);
    return switch (frequency) {
      AutoBackupFrequency.off => false,
      AutoBackupFrequency.daily => diff >= const Duration(days: 1),
      AutoBackupFrequency.weekly => diff >= const Duration(days: 7),
    };
  }

  static String _dateStamp(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _timeStamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$h$m$s$ms';
  }
}
