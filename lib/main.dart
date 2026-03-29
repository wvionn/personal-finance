import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'core/providers/core_providers.dart';
import 'core/services/auto_backup_service.dart';
import 'data/datasources/local_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.ensureInitialized();
  await NotificationService.scheduleRecurringNags();
  final db = await LocalDatabase.open();
  await AutoBackupService.maybeRun(db);
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: CatatUangApp(),
    ),
  );
}
