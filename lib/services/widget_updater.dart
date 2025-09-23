import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:ohmo/db/drift_database.dart' as db;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../const/colors.dart';

class WidgetUpdater {
  static Future<void> update() async {
    final database = db.LocalDatabaseSingleton.instance;
    final today = DateTime.now();

    // 1. 월간 데이터 처리
    final startOfMonth = DateTime(today.year, today.month, 1);
    final endOfMonth = DateTime(today.year, today.month + 1, 0);

    final monthlyTodos = await database.getTodosBetween(startOfMonth, endOfMonth);

    final Map<String, List<Map<String, dynamic>>> groupedTodos = {};
    final formatter = DateFormat('yyyy-MM-dd');

    for (var todo in monthlyTodos) {
      final dateKey = formatter.format(todo.date);
      if (groupedTodos[dateKey] == null) {
        groupedTodos[dateKey] = [];
      }
      groupedTodos[dateKey]!.add({
        'content': todo.content,
        'colorType': ColorType.values[todo.colorType].name,
      });
    }

    await HomeWidget.saveWidgetData<String>(
      'calendar_todos',
      jsonEncode(groupedTodos),
    );

    // 2. 오늘의 할 일 데이터 처리
    final todosForToday = await database.getTodosByDate(today);
    final todoContents =
    todosForToday
        .where((todo) => isSameDay(todo.date, today))
        .map((t) => t.content.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    await HomeWidget.saveWidgetData<String>(
      'today_todo',
      jsonEncode(todoContents),
    );

    // 3. 루틴 데이터 처리
    final routineForToday = await database.getAllRoutines();
    final routineContents =
    routineForToday
        .where((r) => _isRoutineVisibleOnDate(r, today))
        .map((r) => r.content.trim())
        .toList();

    await HomeWidget.saveWidgetData<String>(
      'today_routine',
      jsonEncode(routineContents),
    );

    // 4. 위젯 업데이트
    await HomeWidget.updateWidget(
      name: 'TodayWidgetExtension',
      iOSName: 'TodayWidgetExtension',
    );

    await HomeWidget.updateWidget(
      name: 'HomeWidgetExtension',
      iOSName: 'HomeWidgetExtension',
    );
  }

  static bool _isRoutineVisibleOnDate(db.Routine r, DateTime selectedDate) {
    final dateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    if (r.startDate == null || r.endDate == null || r.weekDays == null)
      return false;

    final start = DateTime(
      r.startDate!.year,
      r.startDate!.month,
      r.startDate!.day,
    );
    final end = DateTime(r.endDate!.year, r.endDate!.month, r.endDate!.day);

    final isWithinRange = !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
    final isWeekdayMatch = r.weekDays!
        .split(',')
        .contains(dateOnly.weekday.toString());
    return isWithinRange && isWeekdayMatch;
  }
}
