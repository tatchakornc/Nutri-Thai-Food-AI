import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tzData.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  /// Schedule end-of-day health reminders at 20:00 daily
  static Future<void> scheduleEndOfDayReminder({
    required int glassesRemaining,
    required double proteinRemaining,
    required double carbsRemaining,
    required int mealsLogged,
    required bool hasLoggedToday,
    String timezone = 'Asia/Bangkok',
  }) async {
    await cancelAll();

    final messages = <String>[];

    if (!hasLoggedToday) {
      messages.add('อย่าลืมบันทึกอาหารวันนี้เพื่อรักษา streak ของคุณ');
    }
    if (glassesRemaining > 0) {
      messages.add(
          'วันนี้คุณยังดื่มน้ำไม่ครบ 8 แก้ว เหลืออีก $glassesRemaining แก้ว');
    }
    if (proteinRemaining > 5) {
      messages.add(
          'วันนี้คุณยังขาดโปรตีนอีก ${proteinRemaining.toStringAsFixed(0)} กรัม');
    }
    if (carbsRemaining > 10) {
      messages.add(
          'วันนี้คุณยังขาดคาร์บอีก ${carbsRemaining.toStringAsFixed(0)} กรัม');
    }
    if (mealsLogged < 3) {
      messages.add('วันนี้คุณยังบันทึกอาหารไม่ครบ 3 มื้อ');
    }

    if (messages.isEmpty) return;

    final tz.TZDateTime scheduledTime = _nextScheduledTime(
      hour: 20,
      minute: 00,
      timezone: timezone,
    );

    for (int i = 0; i < messages.length; i++) {
      await _plugin.zonedSchedule(
        i + 100,
        'NutriThaiFood AI',
        messages[i],
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'การแจ้งเตือนรายวัน',
            channelDescription: 'แจ้งเตือนสุขภาพประจำวัน',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static tz.TZDateTime _nextScheduledTime({
    required int hour,
    required int minute,
    required String timezone,
  }) {
    final location = tz.getLocation(timezone);
    final now = tz.TZDateTime.now(location);
    var scheduled =
        tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant',
          'การแจ้งเตือนทันที',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
