import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/component/main_calendar.dart';
import 'package:ohmo/screen/daylog_screen.dart';
import 'package:ohmo/screen/my_screen.dart';
import 'package:ohmo/component/routine_banner.dart';
import 'package:ohmo/component/routine_card.dart';
import 'package:ohmo/component/todo_banner.dart';
import 'package:ohmo/component/todo_card.dart';
import 'package:ohmo/const/colors.dart';

class Event {
  String title;

  Event(this.title);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // 홈 화면
    HomeScreenBody(),
    DaylogScreen(),
    MyScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items:  [
          BottomNavigationBarItem(
            icon: _selectedIndex==0
            ? SvgPicture.asset('android/assets/images/calendar_selected.svg')
            : SvgPicture.asset('android/assets/images/calendar_unselected.svg'),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex==1
                ? SvgPicture.asset('android/assets/images/daylog_selected.svg')
                : SvgPicture.asset('android/assets/images/daylog_unselected.svg'),
            label: 'Daylog',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex==2
                ? SvgPicture.asset('android/assets/images/my_selected.svg')
                : SvgPicture.asset('android/assets/images/my_unselected.svg'),
            label: 'My',
          ),
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontFamily: 'RubikSprayPaint',
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'RubikSprayPaint',
          fontSize: 12,
        ),
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

  Map<DateTime, List<Event>> events = {
    DateTime(2025, 3, 21): [Event('title'), Event('title2')],
    DateTime(2025, 3, 22): [Event('title3')],
  };

  List<String> routines = ['오모 회의', '데이트'];
  List<String> todos = ['코딩하기', '회의', '코딩하기', '회의', '코딩하기', '회의', '코딩하기', '회의'];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainCalendar(
              selectedDate: selectedDate,
              onDaySelected: onDaySelected,
              eventLoader: (day) {
                DateTime normalizedDate = DateTime(
                  day.year,
                  day.month,
                  day.day,
                );
                return events[normalizedDate] ?? [];
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
