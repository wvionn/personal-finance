import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/finance_repository.dart';
import 'notification_service.dart';

/// Fires at most once per calendar day after noon if there are zero entries.
class IdleTransactionNudge {
  static const _prefKey = 'idle_nudge_fired_ymd';

  static Future<void> maybeAfterDashboardLoad(FinanceRepository repo) async {
    final now = DateTime.now();
    if (now.hour < 12) return;

    if (await repo.hasAnyTransactionOn(now)) return;

    final prefs = await SharedPreferences.getInstance();
    final ymd =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (prefs.getString(_prefKey) == ymd) return;

    await prefs.setString(_prefKey, ymd);
    await NotificationService.showIdleNoTransactionToday();
  }
}
