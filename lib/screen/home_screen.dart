import 'package:flutter/material.dart';
import 'package:ohmo/component/main_calendar.dart';
import 'package:ohmo/screen/daylog_screen.dart';
import 'package:ohmo/screen/my_screen.dart';
import 'package:ohmo/component/routine_banner.dart';
import 'package:ohmo/component/routine_card.dart';
import 'package:ohmo/component/todo_banner.dart';
import 'package:ohmo/component/todo_card.dart';
import 'package:ohmo/component/bottom_navigation_bar.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../const/colors.dart';
import '../customize_category.dart';
import '../db/drift_database.dart' as db;
import '../models/routine.dart';
import '../models/todo.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier(DateTime.now());
  final ValueNotifier<List<Routine>> _routinesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Todo>> _todosNotifier = ValueNotifier([]);
  bool _hideRoutineUI = false;
  bool _hideTodoUI = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _loadRoutineDeletionStatus();
    _loadTodoDeletionStatus();

    final today = DateTime.now();
    _loadDataForDate(today);
  }

  Future<void> _loadDataForDate(DateTime date) async {
    final routines = await fetchRoutines(date);
    _routinesNotifier.value = routines;

    final todos = await fetchTodos(date);
    _todosNotifier.value = todos;

    if (mounted) {
      setState(() {});
    }

    await saveTodayRoutineAndTodo(date, _routinesNotifier.value, _todosNotifier.value);
  }

  Future<List<Routine>> fetchRoutines(DateTime date) async {
    final database = db.LocalDatabaseSingleton.instance;
    final fetched = await database.getAllRoutines();
    return fetched.map((r) {
      return Routine(
        id: r.id,
        content: r.content,
        colorType: ColorType.values[r.colorType],
        isDone: r.isDone,
        startDate: r.startDate ?? DateTime.now(),
        endDate: r.endDate ?? DateTime.now(),
        daysOfWeek: parseWeekDays(r.weekDays),
        time: convertMinutesToTime(r.timeMinutes),
        alarm: false,
      );
    }).toList();
  }

  Future<List<Todo>> fetchTodos(DateTime date) async {
    final database = db.LocalDatabaseSingleton.instance;
    final fetched = await database.getAllTodos();
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
          .map((e) => dayMap[e.trim().toUpperCase()] ?? 0)
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

  ColorType parseColorType(String colorString) {
    try {
      return ColorTypeExtension.fromString(colorString);
    } catch (e) {
      return ColorType.pinkLight;
    }
  }

  Future<List<int>> loadCompletedTodoIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completedTodoIds');
    if (list == null) return [];
    return list.map(int.parse).toList();
  }

  Future<void> saveTodayRoutineAndTodo(DateTime date, List<Routine> routines, List<Todo> todos) async {
    final routineContents =
    routines.where((r) => isRoutineVisibleOnDate(r, date)).map((r) => r.content.trim()).toList();
    final todoContents = todos.map((t) => t.content.trim()).where((e) => e.isNotEmpty).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('todayRoutineContents', routineContents);
    await prefs.setStringList('todayTodoContents', todoContents);

    await HomeWidget.saveWidgetData('today_routine', jsonEncode(routineContents));
    await HomeWidget.saveWidgetData('today_todo', jsonEncode(todoContents));
    await HomeWidget.updateWidget(name: 'TodayWidgetExtension', iOSName: 'TodayWidgetExtension');
    await HomeWidget.updateWidget(name: 'HomeWidgetExtension', iOSName: 'HomeWidgetExtension');
  }

  bool isRoutineVisibleOnDate(Routine routine, DateTime selectedDate) {
    final dateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final start = DateTime(routine.startDate!.year, routine.startDate!.month, routine.startDate!.day);
    final end = DateTime(routine.endDate.year, routine.endDate.month, routine.endDate.day);
    return !dateOnly.isBefore(start) && !dateOnly.isAfter(end) && routine.daysOfWeek.contains(dateOnly.weekday);
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

  void _onDateChanged(DateTime newDate) async {
    _selectedDateNotifier.value = newDate;

    final allRoutines = await fetchRoutines(newDate);
    debugPrint('전체 루틴 갯수: ${allRoutines.length}');
    for (var r in allRoutines) {
      debugPrint('루틴: ${r.content}, 시작: ${r.startDate}, 종료: ${r.endDate}, 요일: ${r.daysOfWeek}');
    }

    final filteredRoutines = allRoutines.where((r) => isRoutineVisibleOnDate(r, newDate)).toList();
    debugPrint('선택 날짜에 맞는 루틴 갯수: ${filteredRoutines.length}');
    for (var r in filteredRoutines) {
      debugPrint('선택 날짜 루틴: ${r.content}');
    }
    _routinesNotifier.value = filteredRoutines;

    if (mounted) {
      setState(() {});
      debugPrint('UI 갱신 완료');
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
        onRoutineAdded: () => _loadDataForDate(_selectedDateNotifier.value),
        onTodoAdded: () => _loadDataForDate(_selectedDateNotifier.value),
        onDataChanged: () => _loadDataForDate(_selectedDateNotifier.value),
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
  final VoidCallback? onDataChanged;
  final VoidCallback? onRoutineAdded;
  final VoidCallback? onTodoAdded;
  final ValueChanged<DateTime>? onDateChanged;
  final bool hideRoutineUI;
  final bool hideTodoUI;

  const HomeScreenBody({
    Key? key,
    required this.routinesNotifier,
    required this.todosNotifier,
    required this.selectedDateNotifier,
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
    final start = DateTime(routine.startDate!.year, routine.startDate!.month, routine.startDate!.day);
    final end = DateTime(routine.endDate.year, routine.endDate.month, routine.endDate.day);
    return !dateOnly.isBefore(start) && !dateOnly.isAfter(end) && routine.daysOfWeek.contains(dateOnly.weekday);
  }

  bool _isTodoVisible(Todo todo, DateTime date) {
    final todoDate = DateTime(todo.Date.year, todo.Date.month, todo.Date.day);
    final selected = DateTime(date.year, date.month, date.day);
    return todoDate == selected;
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
                MainCalendar(
                  selectedDate: selectedDate,
                  onDaySelected: onDaySelected,
                  eventLoader: (_) => [],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      if (!widget.hideRoutineUI) RoutineBanner(onRoutineAdded: widget.onRoutineAdded ?? () {}),
                      ValueListenableBuilder<List<Routine>>(
                        valueListenable: widget.routinesNotifier,
                        builder: (context, routines, _) {
                          final visibleRoutines =
                          routines.where((r) => _isRoutineVisible(r, selectedDate)).toList();
                          return Column(
                            children: visibleRoutines
                                .map((routine) => RoutineCard(
                              content: routine.content,
                              colorType: routine.colorType,
                              scheduleId: routine.id,
                              isDone: routine.isDone,
                              onEdit: (newContent) async {
                                setState(() {
                                  routine.content = newContent;
                                });
                                widget.onDataChanged?.call();
                              },
                              onStatusChanged: () async {
                                setState(() => routine.isDone = !routine.isDone);
                                await _saveRoutineStatus(routines);
                                widget.onDataChanged?.call();
                              },
                            ))
                                .toList(),
                          );
                        },
                      ),
                      if (!widget.hideTodoUI) ...[
                        SizedBox(height: 20),
                        Divider(color: Colors.grey),
                        TodoBanner(
                          onTodoAdded: widget.onTodoAdded ?? () {},
                          selectedDate: selectedDate,
                        ),
                        ValueListenableBuilder<List<Todo>>(
                          valueListenable: widget.todosNotifier,
                          builder: (context, todos, _) {
                            final visibleTodos =
                            todos.where((t) => _isTodoVisible(t, selectedDate)).toList();
                            return Column(
                              children: visibleTodos
                                  .map((todo) => TodoCard(
                                content: todo.content,
                                colorType: todo.colorType,
                                scheduleId: todo.id,
                                isDone: todo.isDone,
                                onEdit: (newContent) {
                                  setState(() {
                                    todo.content = newContent;
                                  });
                                  widget.onDataChanged?.call();
                                },
                                onStatusChanged: () async {
                                  setState(() => todo.isDone = !todo.isDone);
                                  await _saveTodoStatus(todos);
                                  widget.onDataChanged?.call();
                                },
                              ))
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

  Future<void> _saveRoutineStatus(List<Routine> routines) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = routines.where((r) => r.isDone).map((r) => r.id.toString()).toList();
    await prefs.setStringList('completedRoutineIds', completed);
  }

  Future<void> _saveTodoStatus(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = todos.where((t) => t.isDone).map((t) => t.id.toString()).toList();
    await prefs.setStringList('completedTodoIds', completed);
  }
}
