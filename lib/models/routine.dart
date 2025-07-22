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

  Routine({
    required this.id,
    required this.content,
    required this.colorType,
    required this.startDate,
    required this.endDate,
    required this.daysOfWeek,
    this.time,
    required this.alarm,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    final category = json['category'] ?? {};
    final colorStr = category['color'] ?? 'pinkLight';
    final colorType = ColorTypeExtension.fromString(colorStr);

    return Routine(
      id: json['scheduleId'] ?? 0,
      content: json['content'] ?? '',
      colorType: colorType,
      startDate: DateTime.parse(json['date']),
      endDate: DateTime.parse(json['date']),
      daysOfWeek: [DateTime.parse(json['date']).weekday],
      time: json['time'] ?? '',
      alarm: json['alarm'] ?? false,
    );
  }






}
