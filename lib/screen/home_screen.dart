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
        content: t.content,
        Date: t.date,
        colorType: ColorType.values[t.colorType],
        isDone: t.isDone,
        alarm: false,
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
      print("🧹 [카테고리 정리] 서버 데이터 가져오는 중...");

      final routineCats = await categoryService.getCategories('ROUTINE');
      final todoCats = await categoryService.getCategories('TO_DO');
      final serverCategories = [...routineCats, ...todoCats];

      if (serverCategories.isEmpty) return;

      print("📥 서버 카테고리 로드 완료 (${serverCategories.length}개). 정리 시작!");

      for (var sCat in serverCategories) {
        final serverId = sCat['categoryId'] ?? sCat['id'];
        final name = sCat['name'] ?? sCat['categoryName'];
        final color = sCat['color'];
        // [중요] 서버에서 온 타입이 없으면 기본값 ROUTINE
        final type = sCat['scheduleType'] ?? 'ROUTINE';

        if (serverId == null || name == null) continue;

        // [수정] 이름(name) 뿐만 아니라 타입(type)까지 같은 녀석을 찾습니다.
        final localCats =
            await (database.select(database.categories)
              ..where((c) => c.name.equals(name) & c.type.equals(type))).get();

        for (var lCat in localCats) {
          // 이름과 타입이 다 같은데 ID만 다르다면 -> 병합 대상
          if (lCat.id != serverId) {
            print(
              "🔄 [병합] '${lCat.name}($type)': 로컬ID(${lCat.id}) -> 서버ID($serverId)",
            );

            // 해당 타입에 맞는 테이블만 업데이트 (안전장치)
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

            // 구 버전 카테고리 삭제
            await (database.delete(database.categories)
              ..where((c) => c.id.equals(lCat.id))).go();
          }
        }

        // 서버 정보로 로컬 DB 갱신 (Insert or Update)
        await database
            .into(database.categories)
            .insertOnConflictUpdate(
              db.CategoriesCompanion.insert(
                id: Value(serverId),
                name: name,
                type: type, // 타입 정보 저장 필수
                color: color ?? '#000000',
              ),
            );
      }

      print("✨ [카테고리 정리] 완료! (ID 9번/10번 분리됨)");
      setState(() {});
    } catch (e) {
      print("❌ 카테고리 정리 중 에러 발생: $e");
    }
  }

  Future<void> _syncDailyApiDataToLocalDb(
      DailyScheduleData data,
      DateTime date,
      ) async {
    final database = db.LocalDatabaseSingleton.instance;
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    // ============================================================
    // 1) 서버 데이터 분석 (오늘 날짜 기준)
    // ============================================================

    // 오늘의 서버 Todo ID 목록
    final serverTodoIds = data.todoList
        .where((t) => t.scheduleType.toUpperCase() == 'TO_DO')
        .map((t) => t.scheduleId)
        .toSet();

    // 오늘의 서버 Routine UI ID 목록 (scheduleId)
    final serverRoutineUiIds = data.routineList
        .map((r) => r.scheduleId)
        .toSet();

    // 서버 루틴의 routineByDateList에서 오늘 날짜에 해당하는 routineId(apiInstanceId)
    final serverRoutineInstanceIds = <int>{};

    for (var item in data.routineList) {
      if (item.routineByDateList.isNotEmpty) {
        final match = item.routineByDateList.where((x) => x.date == dateString);
        if (match.isNotEmpty) {
          serverRoutineInstanceIds.add(match.first.routineId);
        } else {
          // 오늘 날짜 항목이 없으면 첫 번째 항목을 fallback으로 사용
          serverRoutineInstanceIds.add(item.routineByDateList.first.routineId);
        }
      }
    }

    // ============================================================
    // 2) 로컬 데이터 조회 (오늘 날짜 기준)
    // ============================================================

    // 오늘의 로컬 Todo
    final localTodos = await (database.select(database.todos)..where(
          (t) =>
      t.date.year.equals(date.year) &
      t.date.month.equals(date.month) &
      t.date.day.equals(date.day),
    )).get();

    // 오늘의 로컬 Routine
    final localRoutines = await (database.select(database.routines)..where(
          (r) =>
      r.startDate.isSmallerOrEqualValue(date) &
      r.endDate.isBiggerOrEqualValue(date),
    )).get();

    // ============================================================
    // 3) 로컬에서 “서버에 없는 Todo / 루틴” 삭제 (유령 데이터 제거)
    // ============================================================

    // --- Todo 유령삭제 ---
    for (final local in localTodos) {
      if (!serverTodoIds.contains(local.id)) {
        await (database.delete(database.todos)
          ..where((t) => t.id.equals(local.id))).go();
      }
    }

    // --- Routine 유령삭제 ---
    // 로컬에서는 UI ID(id) 또는 실제 RoutineId(routineId) 중 어느 것이든
    // 서버 오늘 목록과 매칭되지 않으면 삭제
    for (final local in localRoutines) {
      final isMatchedByUiId = serverRoutineUiIds.contains(local.id);
      final isMatchedByInstanceId = serverRoutineInstanceIds.contains(local.routineId);

      if (!isMatchedByUiId && !isMatchedByInstanceId) {
        await (database.delete(database.routines)
          ..where((r) => r.id.equals(local.id))).go();
      }
    }

    // ============================================================
    // 4) 서버 Todo 저장 (insert/update)
    // ============================================================

    for (var item in data.todoList) {
      if (item.scheduleType.toUpperCase() != 'TO_DO') continue;

      try {
        await database.into(database.todos).insertOnConflictUpdate(
          db.TodosCompanion.insert(
            id: Value(item.scheduleId),
            content: item.content,
            groupId: const Value(null),
            date: date,
            colorType:
            Value(_parseColorType(item.category.color).index),
            isDone: Value(item.todo?.status ?? false),
          ),
        );
      } catch (e) {
        print("Todo 저장 오류: $e");
      }
    }

    // ============================================================
    // 5) 서버 Routine 저장 (insert/update)
    // ============================================================

    for (var item in data.routineList) {
      try {
        int uiScheduleId = item.scheduleId; // 고정 UI ID
        int apiInstanceId = uiScheduleId;  // 기본값

        bool isServerDone = false;

        // 오늘에 해당하는 routineByDate 찾기
        if (item.routineByDateList.isNotEmpty) {
          final matched = item.routineByDateList.where((e) => e.date == dateString);
          if (matched.isNotEmpty) {
            apiInstanceId = matched.first.routineId;
            isServerDone = matched.first.status;
          } else {
            apiInstanceId = item.routineByDateList.first.routineId;
            isServerDone = item.routineByDateList.first.status;
          }
        }

        // weekDays 계산
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

        // 오늘 요일도 포함
        weekInts.add(date.weekday);
        final newWeekDays = weekInts.toList()..sort();
        final weekStr = newWeekDays.join(',');

        // 카테고리 ID 매핑
        int? resolvedCategoryId;
        final categoryList = await database.categories.select().get();
        final match =
            categoryList.where((c) => c.name == item.category.categoryName).firstOrNull;
        if (match != null) resolvedCategoryId = match.id;

        // timeMinutes 파싱
        int? parsedTimeMinutes;
        if (item.time != null && item.time!.contains(':')) {
          final parts = item.time!.split(':');
          parsedTimeMinutes =
              int.parse(parts[0]) * 60 + int.parse(parts[1]);
        }

        // endDate
        DateTime? parsedEndDate;
        try {
          parsedEndDate = DateTime.parse(item.date);
        } catch (e) {
          parsedEndDate = DateTime(3000, 12, 31);
        }

        // insert/update
        await database.into(database.routines).insertOnConflictUpdate(
          db.RoutinesCompanion(
            id: Value(uiScheduleId),
            routineId: Value(apiInstanceId),
            content: Value(item.content),
            colorType: Value(_parseColorType(item.category.color).index),
            weekDays: Value(weekStr),
            categoryId: Value(resolvedCategoryId),
            startDate: Value(date),
            endDate: Value(parsedEndDate),
            timeMinutes: Value(parsedTimeMinutes),
            alarmMinutes:
            Value(item.alarmTime != null ? 0 : null),
            isSynced: Value(true),
          ),
        );

        // 완료 여부 동기화
        final completedIds = await database.getCompletedRoutineIds(date);
        final isLocalDone = completedIds.contains(uiScheduleId);

        if (isServerDone != isLocalDone) {
          await database.toggleRoutineCompletion(uiScheduleId, date);
        }

      } catch (e) {
        print("Routine 저장 오류 (${item.scheduleId}): $e");
      }
    }

    print("🎉 [SYNC] 동기화 완료 – 유령데이터 없이 정상 동기화됨!");
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
    final currentTodo = await db.LocalDatabaseSingleton.instance.getTodoById(
      todo.id,
    );
    if (currentTodo == null || !mounted) return;

    final result = await showModalBottomSheet<dynamic>(
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
          (context) => TodoAlarm(
            currentDate: currentTodo.date,
            todoId: currentTodo.id,
            onDataChanged: widget.onDataChanged,
          ),
    );

    if (result != null && result is DateTime) {
      await db.LocalDatabaseSingleton.instance.updateTodoDate(
        currentTodo.id,
        result,
      );
      widget.onDataChanged?.call();
    } else if (result != null && result == 0) {
      await db.LocalDatabaseSingleton.instance.updateTodo(
        db.TodosCompanion(id: Value(currentTodo.id), alarmMinutes: Value(null)),
      );
      await NotificationService().cancelNotification(currentTodo.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('알람이 삭제되었습니다!')));
      }
      widget.onDataChanged?.call();
    } else if (result != null && result is int && result > 0) {
      final minutes = result;

      await db.LocalDatabaseSingleton.instance.updateTodo(
        db.TodosCompanion(
          id: Value(currentTodo.id),
          alarmMinutes: Value(minutes),
        ),
      );
      final updatedTodo = await db.LocalDatabaseSingleton.instance.getTodoById(
        currentTodo.id,
      );
      if (updatedTodo == null) return;

      final notificationTime = updatedTodo.date.subtract(
        Duration(minutes: minutes),
      );

      final originalTimeStr = DateFormat('HH:mm').format(updatedTodo.date);

      await (db.LocalDatabaseSingleton.instance.delete(
        db.LocalDatabaseSingleton.instance.notifications,
      )..where((tbl) => tbl.content.like('%${updatedTodo.content}%'))).go();

      if (notificationTime.isAfter(DateTime.now())) {
        await NotificationService().cancelNotification(updatedTodo.id);
        await NotificationService().scheduleNotification(
          id: updatedTodo.id,
          title: '오늘의 할 일!',
          body: updatedTodo.content,
          scheduledTime: notificationTime,
          payload: 'todo_${updatedTodo.id}',
        );
        try {
          await db.LocalDatabaseSingleton.instance
              .into(db.LocalDatabaseSingleton.instance.notifications)
              .insert(
                db.NotificationsCompanion.insert(
                  type: 'calender',
                  content: '[To-do] $originalTimeStr ${updatedTodo.content}',
                  timestamp: notificationTime,
                  isRead: const Value(false),
                ),
              );
        } catch (e) {}
      } else {}
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${minutes}분 전 알람이 설정되었습니다!')));
      }
      widget.onDataChanged?.call();
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

                                          // ▼▼▼ [수정된 부분] ▼▼▼
                                          // RoutineCard 내부에서 이미 API 통신과 DB 저장을 완료했습니다.
                                          // 여기서는 데이터가 변경되었으니 "화면을 다시 그려라"는 명령만 하면 됩니다.
                                          onStatusChanged: () async {
                                            widget.onDataChanged?.call();
                                          },

                                          // ▲▲▲ [수정 끝] ▲▲▲
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
                                            final newIsDone = !todo.isDone;

                                            try {
                                              await db
                                                  .LocalDatabaseSingleton
                                                  .instance
                                                  .updateTodo(
                                                    db.TodosCompanion(
                                                      id: Value(todo.id),
                                                      isDone: Value(newIsDone),
                                                    ),
                                                  );
                                              setState(() {
                                                todo.isDone = newIsDone;
                                              });

                                              widget.onDataChanged?.call();
                                            } catch (e) {
                                              print("Todo 업데이트 실패: $e");
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
