import 'package:ohmo/const/colors.dart';

class Todo {
  final int id;
  String content;
  final ColorType colorType;
  final DateTime Date;
  final String? time;
  final bool alarm;
  bool isDone;

  Todo({
    required this.id,
    required this.content,
    required this.colorType,
    required this.Date,
    this.time,
    required this.alarm,
    required this.isDone,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    final category = json['category'] ?? {};
    final colorStr = category['color'] ?? 'pinkLight';
    final colorType = ColorTypeExtension.fromString(colorStr);

    return Todo(
      id: json['scheduleId'] ?? 0,
      content: json['content'] ?? '',
      colorType: colorType,
      Date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      alarm: json['alarm'] ?? false,
      isDone: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'colorType': colorType.toString().split('.').last,
      'date': Date.toIso8601String(),
      'time': time,
      'alarm': alarm,
      'isDone': isDone,
    };
  }
}

