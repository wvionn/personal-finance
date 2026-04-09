import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'budget_nudge_messages.dart';

const _channelId = 'catat_uang_budget_nag';
const _channelName = 'Money attitude checks';

/// Local sarcastic reminders — afternoons, evenings, + optional idle-day ping.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  static NotificationDetails _details() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription:
            'Sarcastic reminders to log money like an adult (ish).',
        importance: Importance.defaultImportance,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  static int _daySeed() {
    final n = DateTime.now();
    return n.year * 400 + n.month * 32 + n.day;
  }

  /// Daily: 12:30, 13:45 (afternoon window), 20:00, 21:30 (night window).
  static Future<void> scheduleRecurringNags() async {
    await ensureInitialized();

    await _plugin.cancel(401);
    await _plugin.cancel(402);
    await _plugin.cancel(403);
    await _plugin.cancel(404);

    final d = _details();
    final seed = _daySeed();

    await _plugin.zonedSchedule(
      401,
      'Anti Boncos · siang',
      BudgetNudgeMessages.afternoon(seed),
      _nextInstanceOf(12, 30),
      d,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await _plugin.zonedSchedule(
      402,
      'Anti Boncos · masih siang',
      BudgetNudgeMessages.afternoonLate(seed + 1),
      _nextInstanceOf(13, 45),
      d,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await _plugin.zonedSchedule(
      403,
      'Anti Boncos · malam',
      BudgetNudgeMessages.evening(seed + 2),
      _nextInstanceOf(20, 0),
      d,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await _plugin.zonedSchedule(
      404,
      'Anti Boncos · bablas',
      BudgetNudgeMessages.night(seed + 3),
      _nextInstanceOf(21, 30),
      d,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var s = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!s.isAfter(now)) {
      s = s.add(const Duration(days: 1));
    }
    return s;
  }

  /// One-shot passive-aggressive ping when the day is still empty (from app).
  static Future<void> showIdleNoTransactionToday() async {
    await ensureInitialized();
    await _plugin.show(
      499,
      'Anti Boncos',
      BudgetNudgeMessages.idleRandom(),
      _details(),
    );
  }

  /// Immediately fires a test notification with a custom [id], [title], and [body].
  /// Used by the Settings screen so the user can preview each notification type.
  static Future<void> showTestNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await ensureInitialized();
    await _plugin.show(id, title, body, _details());
  }
}
