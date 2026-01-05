import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ohmo/component/main_calendar.dart';
import 'package:ohmo/component/todo_bottom_sheet.dart';
import 'package:ohmo/models/monthly_schedule_response.dart';
import 'package:ohmo/models/daily_schedule_response.dart';
import 'package:ohmo/screen/daylog_screen.dart';
import 'package:ohmo/screen/my_screen.dart';
import 'package:ohmo/component/routine_banner.dart';
import 'package:ohmo/component/routine_card.dart';
import 'package:ohmo/component/todo_banner.dart';
import 'package:ohmo/component/todo_card.dart';
import 'package:ohmo/component/bottom_navigation_bar.dart';
import 'package:ohmo/services/calendar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ohmo/services/widget_updater.dart';
import 'dart:convert';
import '../component/alarm_bottom_sheet.dart';
import '../component/routine_bottom_sheet.dart';
import '../const/colors.dart';
import '../customize_category.dart';
import '../db/drift_database.dart' as db;
import '../models/routine.dart';
import '../models/todo.dart';
import '../services/category_service.dart';
import '../services/notification_service.dart';
import '../services/routine_service.dart';
import '../services/sync_service.dart';
import '../services/todo_service.dart';
import 'notification_screen.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;
  final bool showTodoSheetForDaylog;

  const HomeScreen({
    Key? key,
    this.initialTabIndex = 0,
    this.showTodoSheetForDaylog = false,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late int _selectedIndex;
  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier(
    DateTime.now(),
  );
  final ValueNotifier<List<Routine>> _routinesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Todo>> _todosNotifier = ValueNotifier([]);
  final ValueNotifier<Map<DateTime, List<Todo>>> _calendarTodosNotifier =
      ValueNotifier({});
  final CalendarService _calendarService = CalendarService();
  late DateTime _currentFocusedMonth;

  bool _hideRoutineUI = false;
  bool _hideTodoUI = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    SyncService().monitorNetwork();
    _loadRoutineDeletionStatus();
    _loadTodoDeletionStatus();
    _syncAndCleanCategories();

    WidgetsBinding.instance.addObserver(this);

    final today = DateTime.now();
    _currentFocusedMonth = DateTime(today.year, today.month);

    _loadDataForDate(today);
    _loadDataForMonth(today);

    _fetchDailyDataAndRefresh(today).then((_) {
      _fetchMonthlyDataAndRefresh(today);
    });
    WidgetUpdater.update();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("앱이 다시 활성화되어 데이터를 새로고침합니다.");
      _loadDataForDate(_selectedDateNotifier.value);
    }
  }

  Future<void> _loadDataForDate(DateTime date) async {
    final routines = await fetchRoutines(date);
    _routinesNotifier.value = routines;

    final todos = await fetchTodos(date);
    _todosNotifier.value = todos;

    if (mounted) {
      setState(() {});
    }
  }

  Future<List<Routine>> fetchRoutines(DateTime date) async {
    final database = db.LocalDatabaseSingleton.instance;
    final allRoutines = await database.getPersonalRoutines();
    final completedIds = await database.getCompletedRoutineIds(date);

    final mappedRoutines =
        allRoutines.map((r) {
          return Routine(
            id: r.id,
            content: r.content,
            colorType: ColorType.values[r.colorType],
            isDone: completedIds.contains(r.id),
            startDate: r.startDate ?? DateTime(2000, 1, 1),
            endDate: r.endDate ?? DateTime(3000, 12, 31),
            daysOfWeek: parseWeekDays(r.weekDays),
            time: convertMinutesToTime(r.timeMinutes),
            alarm: false,
          );
        }).toList();

    return mappedRoutines;
  }

  Future<List<Todo>> fetchTodos(DateTime date) async {
    final database = db.LocalDatabaseSingleton.instance;
    final fetched = await database.getPersonalTodosByDate(date);

    return fetched.map((t) {
      return Todo(
        id: t.id,
        scheduleId: t.scheduleId,
        todoServerId: t.todoServerId,
        content: t.content,
        Date: t.date,
        colorType: ColorType.values[t.colorType],
        isDone: t.isDone,
        alarm: t.alarmMinutes != null,
      );
    }).toList();
  }

  List<int> parseWeekDays(String? weekDaysStr) {
    if (weekDaysStr == null || weekDaysStr.isEmpty) return [];

    const dayMap = {
      'MONDAY': 1,
      'TUESDAY': 2,
      'WEDNESDAY': 3,
      'THURSDAY': 4,
      'FRIDAY': 5,
      'SATURDAY': 6,
      'SUNDAY': 7,
    };

    try {
      return weekDaysStr
          .split(',')
          .map((e) {
            final trimmed = e.trim();
            final asInt = int.tryParse(trimmed);
            if (asInt != null) {
              return asInt;
            }
            return dayMap[trimmed.toUpperCase()] ?? 0;
          })
          .where((e) => e != 0)
          .toList();
    } catch (e) {
      return [];
    }
  }

  String? convertMinutesToTime(int? minutes) {
    if (minutes == null) return null;
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  ColorType _parseColorType(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return ColorType.pinkLight;
    }

    return ColorTypeExtension.fromString(colorString);
  }

  Future<List<int>> loadCompletedTodoIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completedTodoIds');
    if (list == null) return [];
    return list.map(int.parse).toList();
  }

  Future<void> _loadRoutineDeletionStatus() async {
    final isVisible = await RoutineVisibilityHelper.getVisibility();
    setState(() => _hideRoutineUI = !isVisible);
  }

  Future<void> _loadTodoDeletionStatus() async {
    final isVisible = await TodoVisibilityHelper.getVisibility();
    setState(() => _hideTodoUI = !isVisible);
  }

  Future<void> _onTabChange(int index) async {
    setState(() => _selectedIndex = index);
    await _loadRoutineDeletionStatus();
    await _loadTodoDeletionStatus();
  }

  Future<void> _loadDataForMonth(DateTime month) async {
    _currentFocusedMonth = DateTime(month.year, month.month, 1);

    final firstDay = _currentFocusedMonth;
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final database = db.LocalDatabaseSingleton.instance;

    final fetched = await database.getTodosBetween(firstDay, lastDay);

    final monthTodos =
        fetched.map((t) {
          return Todo(
            id: t.id,
            content: t.content,
            Date: t.date,
            colorType: ColorType.values[t.colorType],
            isDone: t.isDone,
            alarm: false,
          );
        }).toList();

    final todoMap = _groupTodosByDay(monthTodos);

    _calendarTodosNotifier.value = todoMap;
  }

  Map<DateTime, List<Todo>> _groupTodosByDay(List<Todo> todos) {
    final Map<DateTime, List<Todo>> map = {};
    for (final todo in todos) {
      final day = DateTime(todo.Date.year, todo.Date.month, todo.Date.day);
      (map[day] ??= []).add(todo);
    }
    return map;
  }

  void _onDateChanged(DateTime newDate) async {
    _selectedDateNotifier.value = newDate;
    await _loadDataForDate(newDate);
    if (newDate.month != _currentFocusedMonth.month ||
        newDate.year != _currentFocusedMonth.year) {
      _currentFocusedMonth = DateTime(newDate.year, newDate.month);

      await _loadDataForMonth(newDate);
      _fetchMonthlyDataAndRefresh(newDate);
    }
    _fetchDailyDataAndRefresh(newDate);
  }

  Future<void> _fetchDailyDataAndRefresh(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return;
      }
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      final response = await _calendarService.getDailySchedule(
        dateString,
        token,
      );

      if (response.isSuccess && response.result != null) {
        await _syncDailyApiDataToLocalDb(response.result!, date);

        await _loadDataForDate(date);
        await _loadDataForMonth(date);
      }
    } catch (e) {
      print("일별 데이터 동기화 에러 : $e");
    }
  }

  Future<void> _syncApiDataToLocalDb(List<DailyScheduleResult> apiData) async {
    final database = db.LocalDatabaseSingleton.instance;
    final selectedDate = _selectedDateNotifier.value;

    for (var dayData in apiData) {
      final date = DateTime.parse(dayData.date);

      final isSelectedDate =
          date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;

      if (isSelectedDate) continue;

      for (var categoryItem in dayData.categoryList) {
        final colorIndex = _parseColorType(categoryItem.color).index;
        final tempContent = categoryItem.categoryName;
        final isRoutine = categoryItem.scheduleType.toUpperCase() == 'ROUTINE';

        if (isRoutine) {
          await (database.delete(database.todos)
            ..where((t) => t.id.equals(categoryItem.id))).go();
        } else {
          final existingTodo =
              await (database.select(database.todos)
                ..where((t) => t.id.equals(categoryItem.id))).getSingleOrNull();

          if (existingTodo != null) continue;

          await database
              .into(database.todos)
              .insert(
                db.TodosCompanion.insert(
                  id: Value(categoryItem.id),
                  groupId: const Value(null),
                  content: tempContent,
                  date: date,
                  colorType: Value(colorIndex),
                  isDone: const Value(false),
                ),
              );
          await (database.delete(database.routines)
            ..where((r) => r.id.equals(categoryItem.id))).go();
        }
      }
    }
  }

  Future<void> _syncAndCleanCategories() async {
    final database = db.LocalDatabaseSingleton.instance;
    final categoryService = CategoryService();

    try {
      final routineCats = await categoryService.getCategories('ROUTINE');
      final todoCats = await categoryService.getCategories('TO_DO');
      final serverCategories = [...routineCats, ...todoCats];

      if (serverCategories.isEmpty) return;

      for (var sCat in serverCategories) {
        final serverId = sCat['categoryId'] ?? sCat['id'];
        final name = sCat['name'] ?? sCat['categoryName'];
        final color = sCat['color'];
        final type = sCat['scheduleType'] ?? 'ROUTINE';

        if (serverId == null || name == null) continue;

        final localCats =
            await (database.select(database.categories)
              ..where((c) => c.name.equals(name) & c.type.equals(type))).get();

        for (var lCat in localCats) {
          if (lCat.id != serverId) {
            if (type == 'ROUTINE') {
              await database.customStatement(
                'UPDATE routines SET category_id = ? WHERE category_id = ?',
                [serverId, lCat.id],
              );
            } else {
              await database.customStatement(
                'UPDATE todos SET category_id = ? WHERE category_id = ?',
                [serverId, lCat.id],
              );
            }

            await (database.delete(database.categories)
              ..where((c) => c.id.equals(lCat.id))).go();
          }
        }

        await database
            .into(database.categories)
            .insertOnConflictUpdate(
              db.CategoriesCompanion.insert(
                id: Value(serverId),
                name: name,
                type: type,
                color: color ?? '#000000',
              ),
            );
      }

      setState(() {});
    } catch (e) {
      print("카테고리 정리 중 에러 발생: $e");
    }
  }

  Future<void> _syncDailyApiDataToLocalDb(
    DailyScheduleData data,
    DateTime date,
  ) async {
    final database = db.LocalDatabaseSingleton.instance;
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final serverTodoIds =
        data.todoList
            .where(
              (t) => t.scheduleType.toUpperCase() == 'TO_DO' && t.todo != null,
            )
            .map((t) => t.scheduleId)
            .toSet();

    final serverRoutineUiIds =
        data.routineList.map((r) => r.scheduleId).toSet();
    final serverRoutineInstanceIds = <int>{};

    for (var item in data.routineList) {
      if (item.routineByDateList.isNotEmpty) {
        final match = item.routineByDateList.where((x) => x.date == dateString);
        if (match.isNotEmpty) {
          serverRoutineInstanceIds.add(match.first.routineId);
        } else {
          serverRoutineInstanceIds.add(item.routineByDateList.first.routineId);
        }
      }
    }
    final localTodos =
        await (database.select(database.todos)..where(
          (t) =>
              t.date.year.equals(date.year) &
              t.date.month.equals(date.month) &
              t.date.day.equals(date.day),
        )).get();

    final localRoutines =
        await (database.select(database.routines)..where(
          (r) =>
              r.startDate.isSmallerOrEqualValue(date) &
              r.endDate.isBiggerOrEqualValue(date),
        )).get();

    for (final local in localTodos) {
      if (!serverTodoIds.contains(local.id)) {
        await (database.delete(database.todos)
          ..where((t) => t.id.equals(local.id))).go();
      }
    }

    for (final local in localRoutines) {
      final isMatchedByUiId = serverRoutineUiIds.contains(local.id);
      final isMatchedByInstanceId = serverRoutineInstanceIds.contains(
        local.routineId,
      );

      if (!isMatchedByUiId && !isMatchedByInstanceId) {
        await (database.delete(database.routines)
          ..where((r) => r.id.equals(local.id))).go();
      }
    }

    await (database.delete(database.todos)..where(
      (t) =>
          t.date.year.equals(date.year) &
          t.date.month.equals(date.month) &
          t.date.day.equals(date.day),
    )).go();

    for (var item in data.todoList) {
      if (item.scheduleType.toUpperCase() != 'TO_DO') continue;
      if (item.todo == null) continue;

      try {
        int? timeMinutesValue;
        int? alarmMinutesValue;

        if (item.time != null && item.time!.contains(':')) {
          final parts = item.time!.split(':');
          timeMinutesValue = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        }
        if (item.alarmTime != null && item.alarmTime!.contains(':')) {
          final parts = item.alarmTime!.split(':');
          alarmMinutesValue = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        }

        DateTime fullDate = date;
        if (timeMinutesValue != null) {
          fullDate = DateTime(
            date.year,
            date.month,
            date.day,
            timeMinutesValue ~/ 60,
            timeMinutesValue % 60,
          );
        }
        int? serverCategoryId = item.category.id;
        await database
            .into(database.todos)
            .insertOnConflictUpdate(
              db.TodosCompanion.insert(
                id: Value(item.scheduleId),
                scheduleId: Value(item.scheduleId),
                todoServerId: Value(item.todo?.todoId),
                content: item.content,
                groupId: const Value(null),
                date: fullDate,
                colorType: Value(_parseColorType(item.category.color).index),
                isDone: Value(item.todo!.status),
                timeMinutes: Value(timeMinutesValue),
                alarmMinutes: Value(alarmMinutesValue),
                categoryId: Value(serverCategoryId),
              ),
            );
      } catch (e) {
        print("Todo 저장 오류: $e");
      }
    }

    for (var item in data.routineList) {
      try {
        int uiScheduleId = item.scheduleId;
        int apiInstanceId = uiScheduleId;
        bool isServerDone = false;

        if (item.routineByDateList.isNotEmpty) {
          final matched = item.routineByDateList.where(
            (e) => e.date == dateString,
          );
          if (matched.isNotEmpty) {
            apiInstanceId = matched.first.routineId;
            isServerDone = matched.first.status;
          } else {
            apiInstanceId = item.routineByDateList.first.routineId;
            isServerDone = item.routineByDateList.first.status;
          }
        }

        final weekInts = <int>{};
        for (var d in item.repeatWeek) {
          switch (d.toUpperCase().trim()) {
            case 'MONDAY':
              weekInts.add(1);
              break;
            case 'TUESDAY':
              weekInts.add(2);
              break;
            case 'WEDNESDAY':
              weekInts.add(3);
              break;
            case 'THURSDAY':
              weekInts.add(4);
              break;
            case 'FRIDAY':
              weekInts.add(5);
              break;
            case 'SATURDAY':
              weekInts.add(6);
              break;
            case 'SUNDAY':
              weekInts.add(7);
              break;
          }
        }
        if (!weekInts.contains(date.weekday)) weekInts.add(date.weekday);
        final newWeekDays = weekInts.toList()..sort();
        final weekStr = newWeekDays.join(',');

        int? resolvedCategoryId;
        final categoryList = await database.categories.select().get();
        final match =
            categoryList
                .where((c) => c.name == item.category.categoryName)
                .firstOrNull;
        if (match != null) resolvedCategoryId = match.id;

        int? parsedTimeMinutes;
        if (item.time != null && item.time!.contains(':')) {
          final parts = item.time!.split(':');
          parsedTimeMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        }

        DateTime? parsedEndDate;
        try {
          parsedEndDate = DateTime.parse(item.date);
        } catch (e) {
          parsedEndDate = DateTime(3000, 12, 31);
        }

        await database
            .into(database.routines)
            .insertOnConflictUpdate(
              db.RoutinesCompanion(
                id: Value(uiScheduleId),
                scheduleId: Value(uiScheduleId),
                routineId: Value(apiInstanceId),
                content: Value(item.content),
                colorType: Value(_parseColorType(item.category.color).index),
                weekDays: Value(weekStr),
                categoryId: Value(resolvedCategoryId),
                startDate: Value(date),
                endDate: Value(parsedEndDate),
                timeMinutes: Value(parsedTimeMinutes),
                alarmMinutes: Value(item.alarmTime != null ? 0 : null),
                isSynced: Value(true),
              ),
            );

        final completedIds = await database.getCompletedRoutineIds(date);
        final isLocalDone = completedIds.contains(uiScheduleId);

        if (isServerDone != isLocalDone) {
          await database.toggleRoutineCompletion(uiScheduleId, date);
        }
      } catch (e) {
        print("Routine 저장 오류 (${item.scheduleId}): $e");
      }
    }
  }

  Future<void> _fetchMonthlyDataAndRefresh(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        print("토큰이 없습니다. 로그인 필요");
        return;
      }

      final yearMonth = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      final apiResult = await _calendarService.getMonthlySchedule(
        yearMonth,
        token,
      );

      await _syncApiDataToLocalDb(apiResult);

      await _loadDataForMonth(date);
      await _loadDataForDate(date);
    } catch (e) {
      print("서버 동기화 실패(오프라인 상태일 수 있음) : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreenBody(
        routinesNotifier: _routinesNotifier,
        todosNotifier: _todosNotifier,
        selectedDateNotifier: _selectedDateNotifier,
        hideRoutineUI: _hideRoutineUI,
        hideTodoUI: _hideTodoUI,
        onDateChanged: _onDateChanged,
        calendarTodosNotifier: _calendarTodosNotifier,
        onPageChanged: _loadDataForMonth,

        onRoutineAdded: () async {
          await _loadDataForDate(_selectedDateNotifier.value);
          await _loadDataForMonth(_selectedDateNotifier.value);
          await WidgetUpdater.update();
        },
        onTodoAdded: () async {
          await _loadDataForDate(_selectedDateNotifier.value);
          await _loadDataForMonth(_selectedDateNotifier.value);
          await WidgetUpdater.update();
        },
        onDataChanged: () async {
          await _loadDataForDate(_selectedDateNotifier.value);
          await _loadDataForMonth(_selectedDateNotifier.value);
          await WidgetUpdater.update();
        },
      ),
      DaylogScreen(
        onTabChange: _onTabChange,
        selectedDateNotifier: _selectedDateNotifier,
        showTodoSheet: widget.showTodoSheetForDaylog,
        selectedDate: _selectedDateNotifier.value,
        routines: _routinesNotifier.value,
        todos: _todosNotifier.value,
      ),
      MyScreen(
        onTabChange: _onTabChange,
        selectedDateNotifier: _selectedDateNotifier,
        onDataChanged: () async {
          await _loadDataForDate(_selectedDateNotifier.value);
          await WidgetUpdater.update();
        },
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: OhmoBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}

// ------------------- HomeScreenBody -------------------

class HomeScreenBody extends StatefulWidget {
  final ValueNotifier<List<Routine>> routinesNotifier;
  final ValueNotifier<List<Todo>> todosNotifier;
  final ValueNotifier<DateTime> selectedDateNotifier;
  final ValueNotifier<Map<DateTime, List<Todo>>> calendarTodosNotifier;
  final void Function(DateTime)? onPageChanged;
  final VoidCallback? onDataChanged;
  final Future<void> Function()? onRoutineAdded;
  final Future<void> Function()? onTodoAdded;
  final ValueChanged<DateTime>? onDateChanged;
  final bool hideRoutineUI;
  final bool hideTodoUI;

  const HomeScreenBody({
    Key? key,
    required this.routinesNotifier,
    required this.todosNotifier,
    required this.selectedDateNotifier,
    required this.calendarTodosNotifier,
    this.onPageChanged,
    this.onDataChanged,
    this.onRoutineAdded,
    this.onTodoAdded,
    this.onDateChanged,
    this.hideRoutineUI = false,
    this.hideTodoUI = false,
  }) : super(key: key);

  @override
  _HomeScreenBodyState createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  void onDaySelected(DateTime selectedDate, DateTime focusedDate) async {
    widget.selectedDateNotifier.value = selectedDate;
    widget.onDateChanged?.call(selectedDate);
  }

  bool _isRoutineVisible(Routine routine, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      routine.startDate!.year,
      routine.startDate!.month,
      routine.startDate!.day,
    );
    final end =
        routine.endDate == null
            ? DateTime(3000, 12, 31)
            : DateTime(
              routine.endDate!.year,
              routine.endDate!.month,
              routine.endDate!.day,
            );

    bool isDateRangePass = !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
    bool isWeekDayPass = routine.daysOfWeek.contains(dateOnly.weekday);

    final isVisible =
        !dateOnly.isBefore(start) &&
        !dateOnly.isAfter(end) &&
        routine.daysOfWeek.contains(dateOnly.weekday);

    return isVisible;
  }

  bool _isTodoVisible(Todo todo, DateTime date) {
    final todoDate = DateTime(todo.Date.year, todo.Date.month, todo.Date.day);
    final selected = DateTime(date.year, date.month, date.day);
    return todoDate == selected;
  }

  Future<void> _showTodoAlarmSheet(Todo todo) async {
    // 1. DB에서 최신 투두 정보 가져오기
    final currentTodo = await db.LocalDatabaseSingleton.instance.getTodoById(
      todo.id,
    );
    if (currentTodo == null || !mounted) return;

    // 2. 알람 설정 바텀시트 띄우기
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(59),
          topLeft: Radius.circular(59),
        ),
      ),
      builder:
          (context) => TodoAlarm(
            currentDate: currentTodo.date,
            todoId: currentTodo.id,
            onDataChanged: widget.onDataChanged,
          ),
    );

    // --- [A] 날짜 변경 처리 ---
    if (result != null && result is DateTime) {
      await db.LocalDatabaseSingleton.instance.updateTodoDate(
        currentTodo.id,
        result,
      );
      widget.onDataChanged?.call();
    }
    // --- [B] 알람 삭제 처리 ---
    else if (result != null && result == 0) {
      await db.LocalDatabaseSingleton.instance.updateTodo(
        db.TodosCompanion(id: Value(currentTodo.id), alarmMinutes: Value(null)),
      );
      await NotificationService().cancelNotification(currentTodo.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('알람이 삭제되었습니다!')));
      }
      widget.onDataChanged?.call();
    }
    // --- [C] 미리 알림 설정 처리 (int > 0) ---
    else if (result != null && result is int && result > 0) {
      final minutes = result;

      if (currentTodo.timeMinutes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('시간이 설정된 투두만 미리 알림이 가능합니다.')),
          );
        }
        return;
      }

      // 3. ⭐ 정확한 알람 시각 계산 (날짜 + 시간 - 설정분)
      final DateTime baseDate = DateTime(
        currentTodo.date.year,
        currentTodo.date.month,
        currentTodo.date.day,
      );
      final DateTime actualTodoTime = baseDate.add(
        Duration(minutes: currentTodo.timeMinutes!),
      );
      final DateTime notificationTime = actualTodoTime.subtract(
        Duration(minutes: minutes),
      );

      // 서버 전송용 포맷 (HH:mm:ss)
      final String alarmTimeStr = DateFormat(
        'HH:mm:ss',
      ).format(notificationTime);

      try {
        final todoService = TodoService();
        print(
          '📡 서버에 알람 시각 전송 요청: {scheduleId: ${currentTodo.scheduleId}, alarmTime: $alarmTimeStr}',
        );

        final isServerSuccess = await todoService.updateAlarmTime(
          currentTodo.scheduleId!,
          alarmTimeStr,
        );

        if (isServerSuccess) {
          // 4. 로컬 DB 업데이트
          await db.LocalDatabaseSingleton.instance.updateTodo(
            db.TodosCompanion(
              id: Value(currentTodo.id),
              alarmMinutes: Value(minutes),
            ),
          );

          // 5. 이전 알림 취소 및 새 알림 예약
          await NotificationService().cancelNotification(currentTodo.id);

          if (notificationTime.isAfter(DateTime.now())) {
            final originalTimeStr = DateFormat('HH:mm').format(actualTodoTime);

            await NotificationService().scheduleNotification(
              id: currentTodo.id,
              title: '오늘의 할 일!',
              body: '[To-do] $originalTimeStr ${currentTodo.content}',
              scheduledTime: notificationTime,
              payload: 'todo_${currentTodo.id}',
            );
            print('🔔 로컬 알람 예약 성공: $notificationTime');

            // 6. 알림함 DB 기록
            try {
              await (db.LocalDatabaseSingleton.instance.delete(
                db.LocalDatabaseSingleton.instance.notifications,
              )..where(
                (tbl) => tbl.content.like('%${currentTodo.content}%'),
              )).go();

              await db.LocalDatabaseSingleton.instance
                  .into(db.LocalDatabaseSingleton.instance.notifications)
                  .insert(
                    db.NotificationsCompanion.insert(
                      type: 'calender',
                      content:
                          '[To-do] $originalTimeStr ${currentTodo.content}',
                      timestamp: notificationTime,
                      isRead: const Value(false),
                    ),
                  );
            } catch (e) {}
          } else {
            print('⚠️ 알람 시각이 이미 지났습니다. (과거 시점)');
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${minutes}분 전 알람이 설정되었습니다!')),
            );
          }
          widget.onDataChanged?.call();
        } else {
          print('❌ 서버 응답 실패');
        }
      } catch (e) {
        print("🚨 오류: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: ValueListenableBuilder<DateTime>(
        valueListenable: widget.selectedDateNotifier,
        builder: (context, selectedDate, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<List<db.Notification>>(
                  stream:
                      db.LocalDatabaseSingleton.instance
                          .watchAllNotifications(),
                  builder: (context, snapshot) {
                    final notifications = snapshot.data ?? [];
                    final now = DateTime.now();

                    final int unreadCount =
                        notifications.where((n) {
                          final isTimeArrived =
                              n.timestamp.isBefore(now) ||
                              n.timestamp.isAtSameMomentAs(now);
                          return !n.isRead && isTimeArrived;
                        }).length;
                    final bool hasUnread = unreadCount > 0;

                    return ValueListenableBuilder<Map<DateTime, List<Todo>>>(
                      valueListenable: widget.calendarTodosNotifier,
                      builder: (context, calendarEvents, child) {
                        return MainCalendar(
                          selectedDate: selectedDate,
                          onDaySelected: onDaySelected,
                          eventLoader: (day) {
                            final normalizedDay = DateTime(
                              day.year,
                              day.month,
                              day.day,
                            );
                            return calendarEvents[normalizedDay] ?? [];
                          },
                          onPageChanged: widget.onPageChanged,
                          hasUnread: hasUnread,
                          onAlarmIconPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationScreen(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      if (!widget.hideRoutineUI) ...[
                        RoutineBanner(
                          onAddPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              isDismissible: true,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(59),
                                  topLeft: Radius.circular(59),
                                ),
                              ),
                              builder:
                                  (_) => RoutineBottomSheet(
                                    groupId: null,
                                    onRoutineAdded:
                                        widget.onRoutineAdded ?? () async {},
                                    selectedDate: selectedDate,
                                  ),
                            );
                          },
                        ),
                        ValueListenableBuilder<List<Routine>>(
                          valueListenable: widget.routinesNotifier,
                          builder: (context, routines, _) {
                            final visibleRoutines =
                                routines
                                    .where(
                                      (r) => _isRoutineVisible(r, selectedDate),
                                    )
                                    .toList();
                            return Column(
                              children:
                                  visibleRoutines
                                      .map(
                                        (routine) => RoutineCard(
                                          content: routine.content,
                                          colorType: routine.colorType,
                                          scheduleId: routine.id,
                                          isDone: routine.isDone,
                                          onDataChanged: widget.onDataChanged,

                                          onStatusChanged: () async {
                                            widget.onDataChanged?.call();
                                          },

                                          isColorPickerEnabled: false,
                                          onEditPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              isDismissible: true,
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(59),
                                                  topLeft: Radius.circular(59),
                                                ),
                                              ),
                                              builder:
                                                  (_) => RoutineBottomSheet(
                                                    routineIdToEdit: routine.id,
                                                    onRoutineAdded:
                                                        widget.onRoutineAdded,
                                                    onDataChanged: () async {
                                                      widget.onDataChanged
                                                          ?.call();
                                                    },
                                                    selectedDate: selectedDate,
                                                  ),
                                            );
                                          },
                                        ),
                                      )
                                      .toList(),
                            );
                          },
                        ),
                      ],
                      if (!widget.hideRoutineUI && !widget.hideTodoUI) ...[
                        SizedBox(height: 20),
                        Divider(color: Colors.grey),
                      ],
                      if (!widget.hideTodoUI) ...[
                        TodoBanner(
                          onAddPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              isDismissible: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(59),
                                  topLeft: Radius.circular(59),
                                ),
                              ),
                              builder:
                                  (_) => TodoBottomSheet(
                                    selectedDate: selectedDate,
                                    onTodoAdded:
                                        widget.onTodoAdded ?? () async {},
                                  ),
                            );
                          },
                        ),
                        ValueListenableBuilder<List<Todo>>(
                          valueListenable: widget.todosNotifier,
                          builder: (context, todos, _) {
                            final visibleTodos =
                                todos
                                    .where(
                                      (t) => _isTodoVisible(t, selectedDate),
                                    )
                                    .toList();
                            return Column(
                              children:
                                  visibleTodos
                                      .map(
                                        (todo) => TodoCard(
                                          content: todo.content,
                                          colorType: todo.colorType,
                                          scheduleId: todo.id,
                                          isDone: todo.isDone,
                                          onDataChanged: widget.onDataChanged,
                                          onStatusChanged: () async {
                                            final localDb =
                                                db
                                                    .LocalDatabaseSingleton
                                                    .instance;
                                            final todoService = TodoService();

                                            final newIsDone = !todo.isDone;

                                            await localDb.updateTodoCompletion(
                                              todo.id,
                                              newIsDone,
                                            );

                                            await localDb.toggleTodoCompletion(
                                              todo.id,
                                              widget.selectedDateNotifier.value,
                                            );

                                            widget.onDataChanged?.call();

                                            try {
                                              final serverId =
                                                  todo.todoServerId;

                                              if (serverId == null) {
                                                throw Exception("서버 ID가 없습니다.");
                                              }

                                              final serverResult =
                                                  await todoService
                                                      .toggleTodoStatus(
                                                        serverId,
                                                      );

                                              if (serverResult == null) {
                                                throw Exception('서버 동기화 실패');
                                              }

                                              if (serverResult != newIsDone) {
                                                await localDb
                                                    .updateTodoCompletion(
                                                      todo.id,
                                                      serverResult,
                                                    );
                                                widget.onDataChanged?.call();
                                              }
                                            } catch (e) {
                                              print("투두 상태 변경 실패 (롤백): $e");

                                              await localDb
                                                  .updateTodoCompletion(
                                                    todo.id,
                                                    !newIsDone,
                                                  );
                                              await localDb
                                                  .toggleTodoCompletion(
                                                    todo.id,
                                                    widget
                                                        .selectedDateNotifier
                                                        .value,
                                                  );

                                              widget.onDataChanged?.call();

                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "상태 변경에 실패했습니다. 잠시 후 다시 시도해주세요.",
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          onDateChanged: (id, newDate) async {
                                            await db
                                                .LocalDatabaseSingleton
                                                .instance
                                                .updateTodoDate(id, newDate);
                                            widget.onDataChanged?.call();
                                          },
                                          isColorPickerEnabled: false,
                                          onEditPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              isDismissible: true,
                                              backgroundColor: Colors.white,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                59,
                                                              ),
                                                          topLeft:
                                                              Radius.circular(
                                                                59,
                                                              ),
                                                        ),
                                                  ),
                                              builder:
                                                  (_) => TodoBottomSheet(
                                                    todoIdToEdit: todo.id,
                                                    selectedDate: selectedDate,
                                                    onTodoAdded:
                                                        widget.onTodoAdded,
                                                    onDataChanged: () async {
                                                      widget.onDataChanged
                                                          ?.call();
                                                    },
                                                  ),
                                            );
                                          },
                                          onAlarmPressed: () {
                                            _showTodoAlarmSheet(todo);
                                          },
                                        ),
                                      )
                                      .toList(),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
