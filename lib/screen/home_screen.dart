import 'package:flutter/material.dart';
import 'package:ohmo/component/main_calendar.dart';
import 'package:ohmo/screen/daylog_screen.dart';
import 'package:ohmo/screen/my_screen.dart';
import 'package:ohmo/component/routine_banner.dart';
import 'package:ohmo/component/routine_card.dart';
import 'package:ohmo/component/todo_banner.dart';
import 'package:ohmo/component/todo_card.dart';
import 'package:ohmo/component/bottom_navigation_bar.dart';
import 'package:ohmo/shared_data.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;

  const HomeScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier(DateTime.now());
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    HomeWidget.setAppGroupId('group.ohmo');
    saveTodayRoutineAndTodo();

    // for test
    testCalendarEventSave();

    _selectedIndex = widget.initialTabIndex;

    _screens = [
      HomeScreenBody(
        onDataChanged: saveTodayRoutineAndTodo,
      ),
      DaylogScreen(
        onTabChange: _onTabChange,
        selectedDateNotifier: _selectedDateNotifier,
      ),
      MyScreen(
        onTabChange: _onTabChange,
        selectedDateNotifier: _selectedDateNotifier,
      ),
    ];
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> saveTodayRoutineAndTodo() async {
    final routineContents = routines.map((e) => e.content).toList();
    final todoContents = todos.map((e) => e.content.trim()).where((e) => e.isNotEmpty).toList();

    await HomeWidget.saveWidgetData('today_routine', jsonEncode(routineContents));
    await HomeWidget.saveWidgetData('today_todo', jsonEncode(todoContents));



    await HomeWidget.updateWidget(
      name: 'TodayWidgetExtension',
      iOSName: 'TodayWidgetExtension',
    );
  }

  @override
  Widget build(BuildContext context) {
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

  const HomeScreenBody({Key? key, this.onDataChanged}) : super(key: key);

  @override
  _HomeScreenBodyState createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

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
                  RoutineBanner(),
                  ...routines.map((routine) {
                    return RoutineCard(
                      content: routine.content,
                      onEdit: (newContent) {
                        setState(() {
                          final target = routines.firstWhere((item) => item.id == routine.id);
                          target.content = newContent;
                        });
                        widget.onDataChanged?.call();
                      },
                    );
                  }),
                  SizedBox(height: 20.0),
                  const Divider(color: Colors.grey),
                  TodoBanner(),
                  ...todos.map((todo) {
                    return TodoCard(
                      content: todo.content,
                      onEdit: (newContent) {
                        setState(() {
                          final target = todos.firstWhere((item) => item.id == todo.id);
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
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}
