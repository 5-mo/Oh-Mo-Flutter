import 'dart:convert';

import 'dart:ui';
import 'package:drift/drift.dart' as drift;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ohmo/screen/splash_screen.dart';
import 'package:ohmo/services/member_service.dart';
import 'package:ohmo/services/widget_updater.dart';
import 'package:provider/provider.dart';
import 'package:ohmo/models/profile_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ohmo/services/notification_service.dart';
import 'db/drift_database.dart' as db;
import 'services/auth_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

const platform = MethodChannel('com.example.ohmo/todo_events');

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final database = db.LocalDatabaseSingleton.instance;

  String saveType = 'group';
  final String? serverType = message.data['type'];

  if (serverType == 'GROUP_INVITATION') {
    saveType = 'invitation';
  } else if (serverType == 'SCHEDULE_ALARM') {
    saveType = 'calendar';
  } else if (serverType == 'NOTICE') {
    saveType = 'group';
  }

  await database.insertNotification(
    db.NotificationsCompanion.insert(
      type: saveType,
      content:
          message.notification?.body ??
          message.data['message'] ??
          '새로운 알림이 도착했습니다.',
      timestamp: DateTime.now(),
      isRead: const drift.Value(false),
      relatedId: drift.Value(
        int.tryParse(
          message.data['invitationId']?.toString() ??
              message.data['groupId']?.toString() ??
              '0',
        ),
      ),
    ),
  );
}

void backgroundMain() {
  WidgetsFlutterBinding.ensureInitialized();
  platform.setMethodCallHandler(_handleWidgetMethodCalls);
}

Future<void> clearTokens() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('accessToken');
  await prefs.remove('refreshToken');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {}
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  await initializeDateFormatting('ko_KR');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final callbackHandle = PluginUtilities.getCallbackHandle(backgroundMain);

  final prefs = await SharedPreferences.getInstance();

  final profileData = ProfileData();

  final newToken = await AuthService.refreshToken();
  if (newToken != null) {
    final savedEmail = prefs.getString('userEmail') ?? '';
    final savedNickname = prefs.getString('userNickname') ?? '';
    profileData.setGeustMode(false);
    profileData.updateProfile(
      updateEmail: savedEmail,
      updateNickname: savedNickname,
    );

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      final memberService = MemberService();
      await memberService.updateFcmToken(fcmToken);
      print("FCM Token 등록 성공 : $fcmToken");
    }
    await WidgetUpdater.update();
  } else {
    profileData.setGeustMode(true);
  }
  await prefs.setInt(
    'background_callback_handle',
    callbackHandle!.toRawHandle(),
  );

  platform.setMethodCallHandler(_handleWidgetMethodCalls);

  await NotificationService().init();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final String? serverType = message.data['type'];
    if (serverType == 'GROUP_INVITATION') {
      print("초대 알림은 푸시를 띄우지 않습니다.");
      return;
    }
    print("==== FCM DATA PAYLOAD ====");
    print(message.data);
    print("==========================");

    final String title = message.notification?.title ?? "OhMo";
    final String body =
        message.notification?.body ?? message.data['message'] ?? "";

    final String groupName =
        message.data['groupName'] ?? message.data['title'] ?? "새로운";

    await NotificationService().showImmediateNotification(
      type: message.data['type'] ?? 'group',
      title: groupName,
      body: body,
      groupName: groupName,
      relatedId: int.tryParse(message.data['groupId']?.toString() ?? '0'),
    );
  });

  await HomeWidget.setAppGroupId('group.ohmo');
  //await clearTokens();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileData>.value(value: profileData),
      ],
      child: MaterialApp(
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xFFA8A8A8),
            selectionColor: Color(0xFFA8A8A8),
            selectionHandleColor: Color(0xFFA8A8A8),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFFFFF)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ),

        builder: (context, child) {
          final Size screenSize = MediaQuery.of(context).size;
          final double deviceAspectRatio = screenSize.width / screenSize.height;
          final bool isTablet = screenSize.shortestSide > 600;

          double targetWidth = 400;
          double targetHeight = isTablet ? 844 : (400 / deviceAspectRatio);

          return Container(
            color: Colors.white,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 500 : double.infinity,
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: targetWidth,
                    height: targetHeight,
                    child: child!,
                  ),
                ),
              ),
            ),
          );
        },
        home: Splash(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

Future<dynamic> _handleWidgetMethodCalls(MethodCall call) async {
  if (call.method == 'updateTodosFromWidget') {
    final String jsonString = call.arguments;
    final List<dynamic> updatedTodos = jsonDecode(jsonString);

    final database = db.LocalDatabaseSingleton.instance;
    for (var todoData in updatedTodos) {
      final id = todoData['id'] as int;
      final isDone = todoData['isDone'] as bool;
      await database.updateTodoCompletion(id, isDone);
    }

    await WidgetUpdater.update();
  }
}
