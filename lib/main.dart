import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'core/providers/core_providers.dart';
import 'core/services/auto_backup_service.dart';
import 'data/datasources/local_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await LocalDatabase.open();
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: CatatUangApp(),
    ),
  );

  // Keep first frame fast and resilient in release builds.
  unawaited(_runBackgroundStartup(db));
}

Future<void> _runBackgroundStartup(Database db) async {
  try {
    await NotificationService.ensureInitialized().timeout(
      const Duration(seconds: 8),
    );
    await NotificationService.scheduleRecurringNags().timeout(
      const Duration(seconds: 8),
    );
  } catch (_) {
    // Ignore notification startup failures to avoid app boot deadlocks.
  }

  try {
    await AutoBackupService.maybeRun(db).timeout(const Duration(seconds: 8));
  } catch (_) {
    // Ignore backup failures at startup; user can still use the app.
  }
}
