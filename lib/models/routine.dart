import 'package:ohmo/const/colors.dart';

class Routine {
  final int id;
  String content;
  final ColorType colorType;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> daysOfWeek;
  final String? time;
  final bool alarm;
  bool isDone;

  int completedDays;
  int totalDaysThisWeek;

  Routine({
    required this.id,
    required this.content,
    required this.colorType,
    required this.startDate,
    required this.endDate,
    required this.daysOfWeek,
    this.time,
    required this.alarm,
    this.isDone = false,
    this.completedDays = 0,
    this.totalDaysThisWeek = 0,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    final category = json['category'] ?? {};
    final colorStr = category['color'] ?? 'pinkLight';
    final colorType = ColorTypeExtension.fromString(colorStr);

    final routineDate = DateTime.parse(json['date']);
    final weekday = routineDate.weekday;

    return Routine(
      id: json['scheduleId'] ?? 0,
      content: json['content'] ?? '',
      colorType: colorType,
      startDate: routineDate,
      endDate: routineDate,
      daysOfWeek: [weekday],
      time: json['time'] ?? '',
      alarm: json['alarm'] ?? false,
    );
  }






}
