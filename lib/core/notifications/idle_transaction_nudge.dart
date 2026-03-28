import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/core_providers.dart';
import 'notification_service.dart';

/// Fires at most once per calendar day after noon if there are zero entries.
class IdleTransactionNudge {
  static const _prefKey = 'idle_nudge_fired_ymd';

  static Future<void> maybeAfterDashboardLoad(WidgetRef ref) async {
    final now = DateTime.now();
    if (now.hour < 12) return;

    final repo = ref.read(financeRepositoryProvider);
    if (await repo.hasAnyTransactionOn(now)) return;

    final prefs = await SharedPreferences.getInstance();
    final ymd = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (prefs.getString(_prefKey) == ymd) return;

    await prefs.setString(_prefKey, ymd);
    await NotificationService.showIdleNoTransactionToday();
  }
}
