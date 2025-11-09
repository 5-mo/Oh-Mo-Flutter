import 'dart:convert';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ohmo/screen/home_screen.dart';
import 'package:ohmo/services/widget_updater.dart';
import 'package:provider/provider.dart';
import 'package:ohmo/models/profile_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ohmo/services/notification_service.dart';
import 'db/drift_database.dart' as db;

const platform = MethodChannel('com.example.ohmo/todo_events');

@pragma('vm:entry-point')
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
  await initializeDateFormatting('ko_KR');

  final callbackHandle = PluginUtilities.getCallbackHandle(backgroundMain);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(
    'background_callback_handle',
    callbackHandle!.toRawHandle(),
  );

  platform.setMethodCallHandler(_handleWidgetMethodCalls);

  await NotificationService().init();
  await HomeWidget.setAppGroupId('group.ohmo');
  //await clearTokens();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProfileData())],
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        home: HomeScreen(),
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
