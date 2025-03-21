import 'package:flutter/material.dart';
import 'package:ohmo/component/main_calendar.dart';
import 'package:ohmo/component/routine_banner.dart';
import 'package:ohmo/component/routine_card.dart';
import 'package:ohmo/component/todo_banner.dart';
import 'package:ohmo/component/todo_card.dart';

class Event{
  String title;

  Event(this.title);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  Map<DateTime,List<Event>> events={
    DateTime(2025,3,21):[Event('title'), Event('title2')],
    DateTime(2025,3,22):[Event('title3')],
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MainCalendar(
              selectedDate: selectedDate,
              onDaySelected: onDaySelected,
              eventLoader: (day){
                DateTime normalizedDate=DateTime(day.year,day.month,day.day,);
                return events[normalizedDate] ?? [];
              },
            ),
            Expanded(
              child: Scrollbar(
                thickness: 2.0,
                radius: const Radius.circular(10),
                child: ListView(
                  children: [
                    RoutineBanner(),
                    RoutineCard(content: '오모 회의'),
                    RoutineCard(content: '데이트'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(color: Colors.grey),
                    ),
                    TodoBanner(),
                    TodoCard(content: '코딩'),
                    TodoCard(content: '운동'),
                    TodoCard(content: '코딩'),
                    TodoCard(content: '운동'),
                    TodoCard(content: '코딩'),
                    TodoCard(content: '운동'),
                    TodoCard(content: '코딩'),
                    TodoCard(content: '운동'),
                  ],
                ),
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
