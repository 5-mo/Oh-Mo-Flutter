import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../const/colors.dart';
import '../screen/group/group_main_screen.dart';

class MainCalendar extends StatefulWidget {
  final OnDaySelected onDaySelected;
  final DateTime selectedDate;
  final List Function(DateTime day) eventLoader;

  final TextStyle? headerTextStyle;
  final double? formatButtonSize;
  final EdgeInsetsGeometry? headerPadding;
  final Offset? formatButtonGapOffset;
  final double? dayFontSize;
  final EdgeInsetsGeometry? calendarPadding;
  final String? headerDateFormat;
  final void Function(DateTime)? onPageChanged;

  MainCalendar({
    required this.onDaySelected,
    required this.selectedDate,
    required this.eventLoader,
    this.headerTextStyle,
    this.formatButtonSize,
    this.headerPadding,
    this.formatButtonGapOffset,
    this.dayFontSize,
    this.calendarPadding,
    this.headerDateFormat,
    this.onPageChanged,
  });

  @override
  _MainCalendarState createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildHeader(), _buildCalendar()]);
  }

  Widget _buildHeader() {
    return Padding(
      padding:
          widget.headerPadding ??
          const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat(
              widget.headerDateFormat ?? 'MMM',
              Localizations.localeOf(context).toString(),
            ).format(_focusedDay).toUpperCase(),
            style:
                widget.headerTextStyle ?? _MainCalendarState._headerTextStyle,
          ),
          Row(
            children: [
              Transform.translate(
                offset: widget.formatButtonGapOffset ?? const Offset(20, 0),
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
      icon: SvgPicture.asset(
        assetPath,
        width: widget.formatButtonSize ?? 19.0,
        height: widget.formatButtonSize ?? 19.0,
      ),
      onPressed: () => setState(() => _format = format),
    );
  }

  Widget _buildCalendar() {
    final calendarStyle = CalendarStyle(
      defaultTextStyle: TextStyle(fontSize: widget.dayFontSize ?? 16.0),
      weekendTextStyle: TextStyle(fontSize: widget.dayFontSize ?? 16.0),
      outsideTextStyle: TextStyle(
        fontSize: widget.dayFontSize ?? 16.0,
        color: Colors.grey,
      ),
      selectedTextStyle: TextStyle(
        fontSize: widget.dayFontSize ?? 16.0,
        color: Colors.white,
      ),
      todayTextStyle: TextStyle(
        fontSize: widget.dayFontSize ?? 16.0,
        color: Colors.black,
      ),
      selectedDecoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      //markerSize: 6.0,
      //markersMaxCount: 4,
      //markersAlignment: Alignment(0.0, 5.0),
      //markerMargin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 5.0),
      //markerDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      isTodayHighlighted: true,
      todayDecoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black),
      ),
    );
    final bool isWeekFormat=_format==CalendarFormat.week;
    final double bottomPosition=isWeekFormat?3:1;
    final double calendarRowHeight = isWeekFormat ? 85.0 : 75.0;
    return Container(
      margin:
          widget.calendarPadding ??
          const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: TableCalendar(
        rowHeight: calendarRowHeight,
        onDaySelected: widget.onDaySelected,
        focusedDay: _focusedDay,
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
        calendarStyle: calendarStyle,
        eventLoader: widget.eventLoader,
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },

        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              final event = events.first as CalendarEvent;
              return Positioned(
                left: 0,
                right: 0,
                bottom: bottomPosition,
                child: Center(
                  child:event.isFullyCompleted()
                  ?Image.asset(
                    'android/assets/images/clear_ohmo.png',
                    width: 20,
                    height: 20,
                  )
                  :Container(
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: ColorManager.getColor(
                        ColorType.pinkLight,
                      ).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 8.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  static const TextStyle _headerTextStyle = TextStyle(
    fontFamily: 'RubikSprayPaint',
    fontSize: 36.0,
  );
}
