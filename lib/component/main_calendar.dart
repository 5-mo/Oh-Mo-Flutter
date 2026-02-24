import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../const/colors.dart';
import '../screen/group/group_main_screen.dart';
import '../models/todo.dart';

class MainCalendar extends StatefulWidget {
  final LayerLink? layerLink;
  final OnDaySelected onDaySelected;
  final DateTime selectedDate;
  final List Function(DateTime day) eventLoader;

  final TextStyle? headerTextStyle;
  final double? formatButtonSize;
  final EdgeInsetsGeometry? headerPadding;
  final Offset? monthButtonOffset;
  final Offset? weekButtonOffset;
  final double? dayFontSize;
  final EdgeInsetsGeometry? calendarPadding;
  final String? headerDateFormat;
  final void Function(DateTime)? onPageChanged;
  final VoidCallback? onAlarmIconPressed;
  final double? alarmIconSize;
  final bool hasUnread;
  final ColorType markerColor;

  MainCalendar({
    this.layerLink,
    required this.onDaySelected,
    required this.selectedDate,
    required this.eventLoader,
    this.headerTextStyle,
    this.formatButtonSize,
    this.headerPadding,
    this.monthButtonOffset,
    this.weekButtonOffset,
    this.dayFontSize,
    this.calendarPadding,
    this.headerDateFormat,
    this.onPageChanged,
    this.onAlarmIconPressed,
    this.alarmIconSize,
    required this.hasUnread,
    this.markerColor = ColorType.pinkLight,
  });

  @override
  _MainCalendarState createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  CalendarFormat _format = CalendarFormat.month;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
  }

  @override
  void didUpdateWidget(MainCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        _focusedDay = widget.selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildHeader(), _buildCalendar()]);
  }

  Widget _buildHeader() {
    return Padding(
      padding:
          widget.headerPadding ??
          const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat(
              widget.headerDateFormat ?? '  MMM',
              Localizations.localeOf(context).toString(),
            ).format(_focusedDay).toUpperCase(),
            style:
                widget.headerTextStyle ?? _MainCalendarState._headerTextStyle,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.onAlarmIconPressed != null)
                Builder(
                  builder: (context) {
                    final String iconPath =
                        widget.hasUnread
                            ? 'android/assets/images/notification_on.svg'
                            : 'android/assets/images/notification_off.svg';
                    return IconButton(
                      icon: SvgPicture.asset(
                        iconPath,
                        width:
                            widget.alarmIconSize ??
                            widget.formatButtonSize ??
                            29.0,
                        height:
                            widget.alarmIconSize ??
                            widget.formatButtonSize ??
                            29.0,
                      ),

                      onPressed: widget.onAlarmIconPressed,
                    );
                  },
                ),
              Row(
                children: [
                  CompositedTransformTarget(
                    link: widget.layerLink ?? LayerLink(),
                    child: Row(
                      children: [
                        Transform.translate(
                          offset:
                              widget.monthButtonOffset ?? const Offset(20, -10),
                          child: _buildFormatButton(
                            _format == CalendarFormat.month
                                ? 'android/assets/images/cal_month.svg'
                                : 'android/assets/images/cal_month_unselected.svg',
                            CalendarFormat.month,
                          ),
                        ),
                        Transform.translate(
                          offset:
                              widget.weekButtonOffset ?? const Offset(0, -10),
                          child: _buildFormatButton(
                            _format == CalendarFormat.week
                                ? 'android/assets/images/cal_week_selected.svg'
                                : 'android/assets/images/cal_week.svg',
                            CalendarFormat.week,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
        width: widget.formatButtonSize ?? 22.0,
        height: widget.formatButtonSize ?? 22.0,
      ),
      onPressed: () {
        setState(() {
          _format = format;
          _focusedDay = widget.selectedDate;
        });
      },
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
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      isTodayHighlighted: true,
      todayDecoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black),
      ),
    );
    final bool isWeekFormat = _format == CalendarFormat.week;
    final double bottomPosition = isWeekFormat ? 3 : 1;
    final double calendarRowHeight = isWeekFormat ? 85.0 : 55.0;
    return Container(
      margin:
          widget.calendarPadding ??
          const EdgeInsets.symmetric(horizontal: 25.0),
      child: TableCalendar(
        rowHeight: calendarRowHeight,
        onDaySelected: widget.onDaySelected,
        focusedDay: _focusedDay,
        firstDay: DateTime(1800, 1, 1),
        lastDay: DateTime(3000, 1, 1),
        selectedDayPredicate: (day) {
          return isSameDay(widget.selectedDate, day);
        },
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
          widget.onPageChanged?.call(focusedDay);
        },

        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              final event = events.first;
              final bool isWeekFormat = _format == CalendarFormat.week;
              if (event is CalendarEvent) {
                final double bottomPosition = isWeekFormat ? 3 : -9;
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: bottomPosition,
                  child: Center(
                    child:
                        event.isFullyCompleted()
                            ? Image.asset(
                              'android/assets/images/clear_ohmo.png',
                              width: 20,
                              height: 20,
                            )
                            : Container(
                              width: 40.0,
                              decoration: BoxDecoration(
                                color: ColorManager.getColor(
                                  widget.markerColor,
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
              } else if (event is Todo) {
                final double bottomPositionNew = isWeekFormat ? 14.0 : 0;
                final todos = events.cast<Todo>();
                final todosToShow = todos.take(4).toList();
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: bottomPositionNew,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        todosToShow.map((todo) {
                          return Container(
                            width: 6.0,
                            height: 6.0,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorManager.getColor(todo.colorType),
                            ),
                          );
                        }).toList(),
                  ),
                );
              }
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
