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
import '../models/routine.dart';
import '../models/todo.dart';
import '../services/routine_service.dart';
import '../services/todo_service.dart';

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
  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier(
    DateTime.now(),
  );
  List<Routine> routines = [];
  List<Todo> todos = [];
  bool _hideRoutineUI = false;
  bool _hideTodoUI = false;

  @override
  void initState() {
    super.initState();
    _loadRoutineDeletionStatus();
    _loadTodoDeletionStatus();
    _selectedIndex = widget.initialTabIndex;
    final today = DateTime.now();
    fetchRoutines(today).then((_) {
      fetchTodos(today).then((_) {
        saveTodayRoutineAndTodo();
      });
    });

    fetchTodosByMonth(today);
  }

  void _onDateChanged(DateTime newDate) async {
    _selectedDateNotifier.value = newDate;

    await fetchRoutines(newDate);
    await fetchTodos(newDate);
    await saveTodayRoutineAndTodo();
  }

  Future<void> fetchRoutines(DateTime date) async {
    final token = await getAccessToken();
    if (token == null) {
      return;
    }

    final startDate = date;
    final endDate = date;

    try {
      final fetched = await RoutineService().getRoutines(
        startDate,
        endDate,
        token,
      );
      final completedIds = await loadCompletedRoutineIds();

      for (var routine in fetched) {
        routine.isDone = completedIds.contains(routine.id);
      }

      if (!mounted) return;
      setState(() {
        routines = fetched;
      });
    } catch (e) {
      print('루틴 불러오기 오류: $e');
    }
  }

  Future<void> fetchTodosByMonth(DateTime month) async {
    final token = await getAccessToken();
    if (token == null) {
      return;
    }

    final yearMonth =
        "${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}";

    try {
      final fetched = await TodoService().getTodosByMonth(yearMonth, token);
      final completedIds = await loadCompletedTodoIds();

      List<Todo> todosFromApi = [];
      for (var dayData in fetched) {
        final date = DateTime.parse(dayData['date']);
        final categoryList = dayData['categoryList'] as List<dynamic>;

        for (var category in categoryList) {
          if (category['scheduleType'] == "TO_DO") {
            final todo = Todo(
              id: category['id'],
              content: category['categoryName'],
              Date: date,
              colorType: parseColorType(category['color']),
              isDone: completedIds.contains(category['id']),
              alarm: false,
            );
            todosFromApi.add(todo);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        todos = todosFromApi;
      });
    } catch (e) {
      print('월별 투두 불러오기 오류: $e');
    }
  }

  Future<List<int>> loadCompletedRoutineIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completedRoutineIds');
    if (list == null) return [];
    return list.map(int.parse).toList();
  }

  Future<void> saveCompletedRoutinesLocally(List<Routine> routines) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> completedIds =
        routines.where((t) => t.isDone).map((t) => t.id).toList();
    await prefs.setStringList(
      'completedRoutineIds',
      completedIds.map((e) => e.toString()).toList(),
    );
  }

  Future<List<int>> loadCompletedTodoIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completedTodoIds');
    if (list == null) return [];
    return list.map(int.parse).toList();
  }

  Future<void> saveCompletedTodosLocally(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> completedIds =
        todos.where((t) => t.isDone).map((t) => t.id).toList();
    await prefs.setStringList(
      'completedTodoIds',
      completedIds.map((e) => e.toString()).toList(),
    );
  }

  Future<void> fetchTodos(DateTime date) async {
    final token = await getAccessToken();
    if (token == null) {
      print('토큰 없음. 로그인 필요.');
      return;
    }

    try {
      final fetched = await TodoService().getTodos(date, token);
      final completedIds = await loadCompletedTodoIds();

      for (var todo in fetched) {
        todo.isDone = completedIds.contains(todo.id);
      }

      if (!mounted) return;
      setState(() {
        todos = fetched;
      });
    } catch (e) {
      print('투두 불러오기 오류: $e');
    }
  }

  ColorType parseColorType(String colorString) {
    try {
      return ColorTypeExtension.fromString(colorString);
    } catch (e) {
      return ColorType.pinkLight;
    }
  }

  Future<void> saveTodayRoutineAndTodo() async {
    final today = DateTime.now();

    final routineContents =
        routines
            .where((r) => isRoutineVisibleOnDate(r, today))
            .map((e) => e.content.trim())
            .toList();

    final todoContents =
        todos.map((e) => e.content.trim()).where((e) => e.isNotEmpty).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('todayRoutineContents', routineContents);
    await prefs.setStringList('todayTodoContents', todoContents);

    await HomeWidget.saveWidgetData(
      'today_routine',
      jsonEncode(routineContents),
    );
    await HomeWidget.saveWidgetData('today_todo', jsonEncode(todoContents));

    await HomeWidget.updateWidget(
      name: 'TodayWidgetExtension',
      iOSName: 'TodayWidgetExtension',
    );

    await HomeWidget.updateWidget(
      name: 'HomeWidgetExtension',
      iOSName: 'HomeWidgetExtension',
    );
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> _onTabChange(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    await _loadRoutineDeletionStatus();
    await _loadTodoDeletionStatus();
  }

  bool isRoutineVisibleOnDate(Routine routine, DateTime selectedDate) {
    final dateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final startOnly = DateTime(
      routine.startDate.year,
      routine.startDate.month,
      routine.startDate.day,
    );
    final endOnly = DateTime(
      routine.endDate.year,
      routine.endDate.month,
      routine.endDate.day,
    );

    final inRange = !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
    final isMatchingDay = routine.daysOfWeek.contains(dateOnly.weekday);

    print(
      '루틴 "${routine.content}" 날짜 필터 - inRange: $inRange, isMatchingDay: $isMatchingDay, selectedDate: $dateOnly',
    );

    return inRange && isMatchingDay;
  }

  bool isTodoVisibleOnDate(Todo todo, DateTime selectedDate) {
    final todoDate = DateTime(todo.Date.year, todo.Date.month, todo.Date.day);
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    return todoDate == selected;
  }

  Future<void> _loadRoutineDeletionStatus() async {
    final isVisible = await RoutineVisibilityHelper.getVisibility();
    setState(() {
      _hideRoutineUI = !isVisible;
    });
  }

  Future<void> _loadTodoDeletionStatus() async {
    final isVisible = await TodoVisibilityHelper.getVisibility();
    setState(() {
      _hideTodoUI = !isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _screens = [
      HomeScreenBody(
        onDataChanged: saveTodayRoutineAndTodo,
        routines: routines,
        onRoutineAdded: () => fetchRoutines(_selectedDateNotifier.value),
        todos: todos,
        onTodoAdded: () => fetchTodos(_selectedDateNotifier.value),
        onDateChanged: _onDateChanged,
        hideRoutineUI: _hideRoutineUI,
        hideTodoUI: _hideTodoUI,
      ),
      DaylogScreen(
        onTabChange: _onTabChange,
        selectedDateNotifier: _selectedDateNotifier,
        showTodoSheet: widget.showTodoSheetForDaylog,
        selectedDate: _selectedDateNotifier.value,
        routines: routines,
        todos: todos,
      ),
      MyScreen(
        onTabChange: _onTabChange,
        selectedDateNotifier: _selectedDateNotifier,
      ),
    ];
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: OhmoBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}

class HomeScreenBody extends StatefulWidget {
  final VoidCallback? onDataChanged;
  final VoidCallback? onRoutineAdded;
  final VoidCallback? onTodoAdded;
  final List<Routine> routines;
  final List<Todo> todos;
  final ValueChanged<DateTime>? onDateChanged;
  final bool hideRoutineUI;
  final bool hideTodoUI;

  const HomeScreenBody({
    Key? key,
    this.onDataChanged,
    this.onRoutineAdded,
    required this.routines,
    this.onTodoAdded,
    required this.todos,
    this.onDateChanged,
    this.hideRoutineUI = false,
    this.hideTodoUI = false,
  }) : super(key: key);

  @override
  _HomeScreenBodyState createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) async {
    print('날짜 선택됨: $selectedDate');
    setState(() {
      this.selectedDate = selectedDate;
    });
    widget.onDateChanged?.call(selectedDate);
  }

  bool isRoutineVisibleOnDate(Routine routine, DateTime selectedDate) {
    final dateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final startOnly = DateTime(
      routine.startDate.year,
      routine.startDate.month,
      routine.startDate.day,
    );
    final endOnly = DateTime(
      routine.endDate.year,
      routine.endDate.month,
      routine.endDate.day,
    );

    final inRange = !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
    final isMatchingDay = routine.daysOfWeek.contains(dateOnly.weekday);

    return inRange && isMatchingDay;
  }

  bool isTodoVisibleOnDate(Todo todo, DateTime selectedDate) {
    final todoDate = DateTime(todo.Date.year, todo.Date.month, todo.Date.day);
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    return todoDate == selected;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainCalendar(
              selectedDate: selectedDate,
              onDaySelected: onDaySelected,
              eventLoader: (day) {
                return [];
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  if (!widget.hideRoutineUI)
                    RoutineBanner(
                      onRoutineAdded: widget.onRoutineAdded ?? () {},
                    ),

                  if (!widget.hideRoutineUI)
                    ...widget.routines
                        .where(
                          (routine) =>
                              isRoutineVisibleOnDate(routine, selectedDate),
                        )
                        .map((routine) {
                          return RoutineCard(
                            content: routine.content,
                            colorType: routine.colorType,
                            scheduleId: routine.id,
                            isDone: routine.isDone,
                            onEdit: (newContent) {
                              setState(() {
                                final target = widget.routines.firstWhere(
                                  (item) => item.id == routine.id,
                                );
                                target.content = newContent;
                              });
                              widget.onDataChanged?.call();
                            },
                            onStatusChanged: () async {
                              setState(() {
                                routine.isDone = !routine.isDone;
                              });
                              await SharedPreferences.getInstance().then((
                                prefs,
                              ) {
                                List<int> completed =
                                    widget.routines
                                        .where((x) => x.isDone)
                                        .map((x) => x.id)
                                        .toList();
                                prefs.setStringList(
                                  'completedRoutineIds',
                                  completed.map((e) => e.toString()).toList(),
                                );
                              });
                              widget.onDataChanged?.call();
                            },
                          );
                        })
                        .toList(),



                  if (!widget.hideTodoUI) ...[
                    SizedBox(height: 20.0),
                    const Divider(color: Colors.grey),
                    TodoBanner(
                      onTodoAdded: widget.onTodoAdded ?? () {},
                      selectedDate: selectedDate,
                    ),
                    ...widget.todos
                        .where(
                          (todo) => isTodoVisibleOnDate(todo, selectedDate),
                        )
                        .map(
                          (todo) => TodoCard(
                            content: todo.content,
                            colorType: todo.colorType,
                            scheduleId: todo.id,
                            isDone: todo.isDone,
                            onEdit: (newContent) {
                              setState(() {
                                final target = widget.todos.firstWhere(
                                  (item) => item.id == todo.id,
                                );
                                target.content = newContent;
                              });
                              widget.onDataChanged?.call();
                            },
                            onStatusChanged: () async {
                              setState(() {
                                todo.isDone = !todo.isDone;
                              });
                              await SharedPreferences.getInstance().then((
                                prefs,
                              ) {
                                List<int> completed =
                                    widget.todos
                                        .where((x) => x.isDone)
                                        .map((x) => x.id)
                                        .toList();
                                prefs.setStringList(
                                  'completedTodoIds',
                                  completed.map((e) => e.toString()).toList(),
                                );
                              });
                              widget.onDataChanged?.call();
                            },
                          ),
                        )
                        .toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
