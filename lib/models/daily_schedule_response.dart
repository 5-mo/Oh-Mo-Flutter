import 'package:ohmo/db/drift_database.dart';
import 'package:ohmo/models/monthly_schedule_response.dart';

class DailyScheduleResponse {
  final bool isSuccess;
  final String? code;
  final String? message;
  final DailyScheduleData? result;

  DailyScheduleResponse({
    required this.isSuccess,
    this.code,
    this.message,
    this.result,
  });

  factory DailyScheduleResponse.fromJson(Map<String, dynamic> json) {
    final resultJson = json['result'];
    return DailyScheduleResponse(
      isSuccess: json['isSuccess'] ?? false,
      code: json['code'],
      message: json['message'],
      result:
          (resultJson != null && resultJson is Map<String, dynamic>)
              ? DailyScheduleData.fromJson(resultJson)
              : null,
    );
  }
}

class DailyScheduleData {
  final List<DailyTodoItem> todoList;
  final List<DailyRoutineItem> routineList;

  DailyScheduleData({required this.todoList, required this.routineList});

  factory DailyScheduleData.fromJson(Map<String, dynamic> json) {
    return DailyScheduleData(
      todoList:
          json['todoList'] != null
              ? (json['todoList'] as List)
                  .map((i) => DailyTodoItem.fromJson(i))
                  .toList()
              : [],
      routineList:
          json['routineList'] != null
              ? (json['routineList'] as List)
                  .map((i) => DailyRoutineItem.fromJson(i))
                  .toList()
              : [],
    );
  }
}

class DailyTodoItem {
  final int scheduleId;
  final String date;
  final String content;
  final String scheduleType;
  final ScheduleCategory category;
  final TodoDetail? todo;
  final String? time;
  final String? alarmTime;

  DailyTodoItem({
    required this.scheduleId,
    required this.date,
    required this.content,
    required this.scheduleType,
    required this.category,
    this.todo,
    this.time,
    this.alarmTime,
  });

  factory DailyTodoItem.fromJson(Map<String, dynamic> json) {
    return DailyTodoItem(
      scheduleId: json['scheduleId'] ?? 0,
      date: json['date'] ?? '',
      content: json['content'] ?? '',
      scheduleType: json['scheduleType'] ?? '',
      category: ScheduleCategory.fromJson(json['category'] ?? {}),
      todo: json['todo'] != null ? TodoDetail.fromJson(json['todo']) : null,
      time: json['time'],
      alarmTime: json['alarmTime'],
    );
  }
}

class DailyRoutineItem {
  final int scheduleId;
  final String date;
  final String content;
  final String scheduleType;
  final ScheduleCategory category;
  final List<RoutineDetail> routineByDateList;
  final List<String> repeatWeek;
  final String? time;
  final String? alarmTime;

  DailyRoutineItem({
    required this.scheduleId,
    required this.date,
    required this.content,
    required this.scheduleType,
    required this.category,
    required this.routineByDateList,
    required this.repeatWeek,
    this.time,
    this.alarmTime,
  });

  factory DailyRoutineItem.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    return DailyRoutineItem(
      scheduleId: json['scheduleId'] ?? 0,
      date: json['date'] ?? '',
      content: json['content'] ?? '',
      scheduleType: json['scheduleType'] ?? '',
      category:
          (categoryJson != null && categoryJson is Map<String, dynamic>)
              ? ScheduleCategory.fromJson(categoryJson)
              : ScheduleCategory.fromJson({}),
      routineByDateList:
          json['routineByDateList'] != null
              ? (json['routineByDateList'] as List)
                  .map((i) => RoutineDetail.fromJson(i))
                  .toList()
              : [],
      repeatWeek:
          json['repeatWeek'] != null
              ? List<String>.from(json['repeatWeek'])
              : [],
      time: json['time'],
      alarmTime: json['alarmTime'],
    );
  }
}

class ScheduleCategory {
  final int id;
  final String categoryName;
  final String color;
  final String scheduleType;

  ScheduleCategory({
    required this.id,
    required this.categoryName,
    required this.color,
    required this.scheduleType,
  });

  factory ScheduleCategory.fromJson(Map<String, dynamic> json) {
    return ScheduleCategory(
      id: json['id'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      color: json['color'] ?? '',
      scheduleType: json['scheduleType'] ?? '',
    );
  }
}

class TodoDetail {
  final int todoId;
  final bool status;
  final String date;

  TodoDetail({required this.todoId, required this.status, required this.date});

  factory TodoDetail.fromJson(Map<String, dynamic> json) {
    return TodoDetail(
      todoId: json['todoId'] ?? 0,
      status: json['status'] ?? false,
      date: json['date'] ?? '',
    );
  }
}

class RoutineDetail {
  final int routineId;
  final String date;
  final bool status;
  final String week;

  RoutineDetail({
    required this.routineId,
    required this.date,
    required this.status,
    required this.week,
  });

  factory RoutineDetail.fromJson(Map<String, dynamic> json) {
    return RoutineDetail(
      routineId: json['routineId'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? false,
      week: json['week'] ?? '',
    );
  }
}
