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
import '../models/routine.dart';
import '../models/todo.dart';
import '../services/routine_service.dart';
import '../services/todo_service.dart';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;
  final bool showTodoSheetForDaylog;

  const HomeScreen({Key? key, this.initialTabIndex = 0,this.showTodoSheetForDaylog = false,}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier(DateTime.now());
  List<Routine> routines = [];
  List<Todo> todos = [];


  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    fetchRoutines();
    fetchTodos();
    saveTodayRoutineAndTodo();
  }

  Future<void> fetchRoutines() async {
    final token = await getAccessToken();
    if (token == null) {
      print('토큰 없음. 로그인 필요.');
      return;
    }

    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: 7));

    try {
      final fetched = await RoutineService().getRoutines(startDate, endDate, token);
      print('루틴 데이터 받아옴: ${fetched.length}개');
      if (!mounted) return;
      setState(() {
        routines = fetched;
      });
    } catch (e) {
      print('루틴 불러오기 오류: $e');
    }
  }

  Future<void> fetchTodos() async {
    final token = await getAccessToken();
    if (token == null) {
      print('토큰 없음. 로그인 필요.');
      return;
    }

    final date = DateTime.now();

    try {
      final fetched = await TodoService().getTodos(date, token);
      print('투두 데이터 받아옴: ${fetched.length}개');
      if (!mounted) return;
      setState(() {
        todos = fetched;
      });
    } catch (e) {

      print('투두 불러오기 오류: $e');
    }
  }

  bool isRoutineVisibleOnDate(Routine routine, DateTime selectedDate) {
    final inRange = !selectedDate.isBefore(routine.startDate) &&
        !selectedDate.isAfter(routine.endDate);
    final isMatchingDay = routine.daysOfWeek.contains(selectedDate.weekday);
    print('루틴 "${routine.content}" 날짜 필터 - inRange: $inRange, isMatchingDay: $isMatchingDay, selectedDate: $selectedDate');
    return inRange && isMatchingDay;
  }

  bool isTodoVisibleOnDate(Todo todo, DateTime selectedDate) {
    final todoDate = DateTime(todo.Date.year, todo.Date.month, todo.Date.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return todoDate == selected;
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> saveTodayRoutineAndTodo() async {
    final today = DateTime.now();
    final routineContents = routines
        .where((r) => isRoutineVisibleOnDate(r, today))
        .map((e) => e.content)
        .toList();
    final todoContents = todos.map((e) => e.content.trim()).where((e) => e.isNotEmpty).toList();

    await HomeWidget.saveWidgetData('today_routine', jsonEncode(routineContents));
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

  @override
  Widget build(BuildContext context) {
    final _screens = [
      HomeScreenBody(
        onDataChanged: saveTodayRoutineAndTodo,
        routines: routines,
        onRoutineAdded: fetchRoutines,
        todos:todos,
        onTodoAdded:fetchTodos

      ),
      DaylogScreen(
        onTabChange: _onTabChange,
        selectedDateNotifier: _selectedDateNotifier,
        showTodoSheet: widget.showTodoSheetForDaylog,
        selectedDate: _selectedDateNotifier.value,

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

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}

class HomeScreenBody extends StatefulWidget {
  final VoidCallback? onDataChanged;
  final VoidCallback? onRoutineAdded;
  final VoidCallback? onTodoAdded;
  final List<Routine> routines;
  final List<Todo>todos;
  const HomeScreenBody({Key? key, this.onDataChanged,this.onRoutineAdded, required this.routines,this.onTodoAdded,required this.todos}) : super(key: key);


  @override
  _HomeScreenBodyState createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  bool isRoutineVisibleOnDate(Routine routine, DateTime selectedDate) {
    final dateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final startOnly = DateTime(routine.startDate.year, routine.startDate.month, routine.startDate.day);
    final endOnly = DateTime(routine.endDate.year, routine.endDate.month, routine.endDate.day);

    final inRange = !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
    final isMatchingDay = routine.daysOfWeek.contains(dateOnly.weekday);

    return inRange && isMatchingDay;
  }

  bool isTodoVisibleOnDate(Todo todo, DateTime selectedDate) {
    final todoDate = DateTime(todo.Date.year, todo.Date.month, todo.Date.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
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
                  RoutineBanner(
                    onRoutineAdded: widget.onRoutineAdded ?? () {},
                  ),
                  ...widget.routines
                      .where((routine) => isRoutineVisibleOnDate(routine, selectedDate))
                      .map((routine) {
                    return RoutineCard(
                      content: routine.content,
                      colorType: routine.colorType,
                      onEdit: (newContent) {
                        setState(() {
                          final target = widget.routines.firstWhere((item) => item.id == routine.id);
                          target.content = newContent;
                        });
                        widget.onDataChanged?.call();
                      },
                    );
                  }),
                  SizedBox(height: 20.0),
                  const Divider(color: Colors.grey),
                  TodoBanner(onTodoAdded:widget.onTodoAdded??(){}, selectedDate: selectedDate,),
                  ...widget.todos
                      .where((todo) => isTodoVisibleOnDate(todo,selectedDate))
                      .map((todo) {
                    return TodoCard(
                      content: todo.content,
                      colorType: todo.colorType,
                      onEdit: (newContent) {
                        setState(() {
                          final target = widget.todos.firstWhere((item) => item.id == todo.id);
                          target.content = newContent;
                        });
                        widget.onDataChanged?.call();
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    print('날짜 선택됨: $selectedDate');
    setState(() {
      this.selectedDate = selectedDate;
    });
  }


}
