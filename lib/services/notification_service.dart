import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:drift/drift.dart';
import 'package:ohmo/db/drift_database.dart';

Future<void> _addNotificationToDBFromPayload(String? payload) async {
  if (payload == null || payload.isEmpty) return;

  final parts = payload.split('_');
  if (parts.length != 2) return;

  final type = parts[0];
  final id = int.tryParse(parts[1]);
  if (id == null) return;

  final db = LocalDatabaseSingleton.instance;
  String content = '';

  if (type == 'todo') {
    final todo = await db.getTodoById(id);
    if (todo == null) return;
    content = todo.content;
  } else if (type == 'routine') {
    final routine = await db.getRoutineById(id);
    if (routine == null) return;
    content = routine.content;
  } else {
    return;
  }

  await db.insertNotification(
    NotificationsCompanion(
      type: Value('calender'),
      content: Value(content),
      timestamp: Value(DateTime.now()),
      relatedId: Value(id),
    ),
  );
  print('Notification $payload added to local DB');
}

@pragma('vm:entry-point')
Future<void> onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) async {
  await _addNotificationToDBFromPayload(notificationResponse.payload);
}

class NotificationService {
  NotificationService._privateConstructor();

  static final NotificationService _instance =
      NotificationService._privateConstructor();

  factory NotificationService() {
    return _instance;
  }

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('plus_btn');

    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: darwinInitializationSettings,
        );

    tz.initializeTimeZones();

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> requestIOSPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel_id',
          '일정 알림',
          channelDescription: '등록된 일정에 대한 알림을 보냅니다.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(badgeNumber: 1),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
