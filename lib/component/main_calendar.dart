import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class Event{
  String title;

  Event(this.title);
}

class MainCalendar extends StatefulWidget {
  final OnDaySelected onDaySelected;
  final DateTime selectedDate;
  final List Function(DateTime day) eventLoader;

  MainCalendar({
    required this.onDaySelected,
    required this.selectedDate,
    required this.eventLoader,
  });

  @override
  _MainCalendarState createState() => _MainCalendarState();

}


class _MainCalendarState extends State<MainCalendar> {
  CalendarFormat _format = CalendarFormat.month;

  List<Event> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return widget.eventLoader(normalizedDay)
        .map<Event>((e)=>e is Event? e: Event(e.toString()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(children: [_buildHeader(now), _buildCalendar(now)]);
  }

  Widget _buildHeader(DateTime now) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMM').format(now).toUpperCase(),
            style: _headerTextStyle,
          ),
          Row(
            children: [
              Transform.translate(
                offset: const Offset(20, 0),
                child: _buildFormatButton(
                  'android/assets/images/cal_month.svg',
                  CalendarFormat.month,
                ),
              ),
              _buildFormatButton(
                'android/assets/images/cal_week.svg',
                CalendarFormat.week,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton(String assetPath, CalendarFormat format) {
    return IconButton(
      icon: SvgPicture.asset(assetPath),
      onPressed: () => setState(() => _format = format),
    );
  }

  Widget _buildCalendar(DateTime now) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: TableCalendar(
        onDaySelected: widget.onDaySelected,

        selectedDayPredicate: (date) =>
            date.year == widget.selectedDate.year &&
            date.month == widget.selectedDate.month &&
            date.day == widget.selectedDate.day,
        focusedDay: now,
        firstDay: DateTime(1800, 1, 1),
        lastDay: DateTime(3000, 1, 1),
        calendarFormat: _format,
        onFormatChanged: (format) => setState(() => _format = format),
        availableCalendarFormats: {
          CalendarFormat.month: 'Month',
          CalendarFormat.week: 'Week',
        },
        headerVisible: false,
        daysOfWeekStyle: DaysOfWeekStyle(
          dowTextFormatter:
              (date, locale) =>
              DateFormat('E', locale).format(date).substring(0, 1),
        ),
        calendarStyle: _calendarStyle,
        eventLoader: _getEventsForDay,

      ),
    );
  }

  static const TextStyle _headerTextStyle = TextStyle(
    fontFamily: 'RubikSprayPaint',
    fontSize: 36.0,
  );

  static final CalendarStyle _calendarStyle = CalendarStyle(
    markerSize: 6.0,
    markersAlignment: Alignment(0.0, 5.0),
    markerMargin: EdgeInsets.symmetric(horizontal: 2.0,vertical: 5.0),
    markerDecoration: BoxDecoration(
      color:Colors.red,
      shape:BoxShape.circle
    ),
    isTodayHighlighted: true,
    todayTextStyle: const TextStyle(color: Colors.black),
    todayDecoration: BoxDecoration(
      color: Colors.transparent,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black),
    ),
  );

}
