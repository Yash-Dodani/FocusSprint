import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      print('[NOTIF] init() called but already initialized');
      return;
    }

    print('[NOTIF] Initializing notifications…');

    // Timezone setup (zonedSchedule ke liye zaroori)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // India

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        print('[NOTIF] Notification tapped. payload=${response.payload}');
      },
    );

    _initialized = true;
    print('[NOTIF] Initialization COMPLETE');
  }

  /// Simple helper: Android notification details (default device sound)
  AndroidNotificationDetails _buildAndroidDetails() {
    return const AndroidNotificationDetails(
      'focus_sprint_alarm', // channel id
      'Sprint alarms', // channel name
      channelDescription: 'Alarm when a focus sprint ends',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true, // default notification sound
      enableVibration: true,
      fullScreenIntent: true, // lock screen pe popup allow kare
    );
  }

  /// Schedule an alarm [secondsFromNow] in the future.
  Future<void> scheduleSprintEndAlarm({
    required int id,
    required int secondsFromNow,
    required String title,
  }) async {
    await init();

    final scheduled = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(seconds: secondsFromNow));

    final androidDetails = _buildAndroidDetails();
    final details = NotificationDetails(android: androidDetails);

    print(
      '[NOTIF] Scheduling alarm id=$id for $secondsFromNow s later -> $scheduled',
    );

    await _plugin.zonedSchedule(
      id,
      'Sprint complete 🎉',
      '$title finished. Great job! Tap to start another sprint.',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('[NOTIF] zonedSchedule() call DONE for id=$id');
  }

  /// Immediate alarm (useful if app foreground me ho)
  Future<void> showSprintEndAlarmNow({
    required int id,
    required String title,
  }) async {
    await init();

    final androidDetails = _buildAndroidDetails();
    final details = NotificationDetails(android: androidDetails);

    print('[NOTIF] Showing alarm IMMEDIATELY id=$id');
    await _plugin.show(
      id,
      'Sprint complete 🎉',
      '$title finished. Great job! Tap to start another sprint.',
      details,
    );
  }

  Future<void> cancelNotification(int id) async {
    print('[NOTIF] Cancel alarm id=$id');
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    print('[NOTIF] Cancel ALL alarms');
    await _plugin.cancelAll();
  }
}
