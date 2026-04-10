import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:drift/drift.dart';
import 'package:ohmo/db/drift_database.dart';
import '../db/drift_database.dart';

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
    final prefs = await SharedPreferences.getInstance();

    bool isAllOn = prefs.getBool('all_noti') ?? true;
    bool isCalendarOn = prefs.getBool('calendar_noti') ?? true;

    if (!isAllOn || !isCalendarOn) {
      print('알림 설정이 꺼져 있어 예약을 중단합니다.');
      return;
    }
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

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print("모든 예약 알림이 취소되었습니다.");
  }

  Future<void> cancelPersonalCalendarNotifications() async {
    final database = LocalDatabaseSingleton.instance;

    final personalTodos =
        await (database.select(database.todos)
          ..where((t) => t.groupId.isNull())).get();

    for (var todo in personalTodos) {
      await _flutterLocalNotificationsPlugin.cancel(todo.id);
    }

    final personalRoutines =
        await (database.select(database.routines)
          ..where((r) => r.groupId.isNull())).get();

    for (var routine in personalRoutines) {
      await _cancelRoutineAlarmsOnly(routine.id);
    }
    print("개인 일정 및 루틴 알람이 취소되었습니다.");
  }

  Future<void> _cancelRoutineAlarmsOnly(int routineId) async {
    DateTime today = DateTime.now();
    DateTime startDate = DateTime(today.year, today.month, today.day);

    for (var i = 0; i < 730; i++) {
      DateTime currentDay = startDate.add(Duration(days: i));
      int uniqueNotificationId =
          Object.hash(
            routineId,
            currentDay.year,
            currentDay.month,
            currentDay.day,
          ) &
          0x7FFFFFFF;

      await _flutterLocalNotificationsPlugin.cancel(uniqueNotificationId);
    }
  }

  Future<void> showImmediateNotification({
    required String type,
    required String title,
    required String body,
    int? relatedId,
    String? groupName,
  }) async {
    String pushTitle = "그룹에 새로운 알림이 있습니다";

    String pushBody = body;
    if (!pushBody.contains('[공지]')) {
      pushBody = "[공지] $body";
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'group_notice_channel',
          '그룹 공지 알림',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      pushTitle,
      pushBody,
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      payload: '${type}_$relatedId',
    );
  }
}
