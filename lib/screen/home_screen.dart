import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ohmo/component/main_calendar.dart';
import 'package:ohmo/component/todo_bottom_sheet.dart';
import 'package:ohmo/screen/daylog_screen.dart';
import 'package:ohmo/screen/my_screen.dart';
import 'package:ohmo/component/routine_banner.dart';
import 'package:ohmo/component/routine_card.dart';
import 'package:ohmo/component/todo_banner.dart';
import 'package:ohmo/component/todo_card.dart';
import 'package:ohmo/component/bottom_navigation_bar.dart';
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
import '../services/notification_service.dart';
import 'notification_screen.dart';
import 'package:drift/drift.dart' hide Column;

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
  final ValueNotifier<Map<DateTime,List<Todo>>>_calendarTodosNotifier=
  ValueNotifier({});
  late DateTime _currentFocusedMonth;

  bool _hideRoutineUI = false;
  bool _hideTodoUI = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _loadRoutineDeletionStatus();
    _loadTodoDeletionStatus();

    WidgetsBinding.instance.addObserver(this);

    final today = DateTime.now();
    _currentFocusedMonth=DateTime(today.year,today.month);
    _loadDataForDate(today);
    _loadDataForMonth(today);
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

    return allRoutines.map((r) {
      return Routine(
        id: r.id,
        content: r.content,
        colorType: ColorType.values[r.colorType],
        isDone: completedIds.contains(r.id),
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

    final monthTodos = fetched.map((t) {
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
    await WidgetUpdater.update();
    if (newDate.month != _currentFocusedMonth.month ||
        newDate.year != _currentFocusedMonth.year) {
      await _loadDataForMonth(newDate);
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
    return !dateOnly.isBefore(start) &&
        !dateOnly.isAfter(end) &&
        routine.daysOfWeek.contains(dateOnly.weekday);
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

      final todoTime = updatedTodo.date;
      final notificationTime = todoTime.subtract(Duration(minutes: minutes));

      if (notificationTime.isAfter(DateTime.now())) {
        await NotificationService().cancelNotification(updatedTodo.id);
        await NotificationService().scheduleNotification(
          id: updatedTodo.id,
          title: '오늘의 할 일!',
          body: updatedTodo.content,
          scheduledTime: notificationTime,
          payload: 'todo_${updatedTodo.id}',
        );
      }
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
                StreamBuilder<int>(
                  stream:
                      db.LocalDatabaseSingleton.instance
                          .watchUnreadNotificationCount(),
                  builder: (context, snapshot) {
                    final int unreadCount = snapshot.data ?? 0;
                    final bool hasUnread = unreadCount > 0;

                    return MainCalendar(
                      selectedDate: selectedDate,
                      onDaySelected: onDaySelected,
                      eventLoader: (day) {
                        final normalizedDay =
                        DateTime(day.year, day.month, day.day);
                        return widget.calendarTodosNotifier.value[normalizedDay] ??
                            [];
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      if (!widget.hideRoutineUI)
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
                                          await db
                                              .LocalDatabaseSingleton
                                              .instance
                                              .toggleRoutineCompletion(
                                                routine.id,
                                                selectedDate,
                                              );
                                          setState(
                                            () =>
                                                routine.isDone =
                                                    !routine.isDone,
                                          );
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
                      if (!widget.hideTodoUI) ...[
                        SizedBox(height: 20),
                        Divider(color: Colors.grey),
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
