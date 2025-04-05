import 'package:flutter/material.dart';
import 'package:ohmo/component/main_calendar.dart';
import 'package:ohmo/screen/daylog_screen.dart';
import 'package:ohmo/screen/my_screen.dart';
import 'package:ohmo/component/routine_banner.dart';
import 'package:ohmo/component/routine_card.dart';
import 'package:ohmo/component/todo_banner.dart';
import 'package:ohmo/component/todo_card.dart';
import 'package:ohmo/component/bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier(
    DateTime.now(),
  );
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreenBody(),
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
  @override
  _HomeScreenBodyState createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  List<String> routines = ['오모 회의', '데이트'];
  List<String> todos = ['코딩하기', '회의', '코딩하기', '회의', '코딩하기', '회의', '코딩하기', '회의'];

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
                  ...routines.asMap().entries.map((entry) {
                    int index = entry.key;
                    String routine = entry.value;
                    return RoutineCard(
                      content: routine,
                      onEdit: (newContent) {
                        setState(() {
                          routines[index] = newContent;
                        });
                      },
                    );
                  }).toList(),
                  const Divider(color: Colors.grey),
                  TodoBanner(),
                  ...todos.asMap().entries.map((entry) {
                    int index = entry.key;
                    String todo = entry.value;
                    return TodoCard(
                      content: todo,
                      onEdit: (newContent) {
                        setState(() {
                          todos[index] = newContent;
                        });
                      },
                    );
                  }).toList(),
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
