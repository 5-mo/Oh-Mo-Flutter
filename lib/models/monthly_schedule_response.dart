class MonthlyScheduleResponse {
  final bool isSuccess;
  final String? code;
  final String? message;
  final List<DailyScheduleResult>? result;

  MonthlyScheduleResponse({
    required this.isSuccess,
    this.code,
    this.message,
    this.result,
  });

  factory MonthlyScheduleResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyScheduleResponse(
      isSuccess: json['isSuccess'] ?? false,
      code: json['code'],
      message: json['message'],
      result:
          json['result'] != null
              ? (json['result'] as List)
                  .map((i) => DailyScheduleResult.fromJson(i))
                  .toList()
              : null,
    );
  }
}

class DailyScheduleResult {
  final String date;
  final List<ScheduleCategory> categoryList;

  DailyScheduleResult({required this.date, required this.categoryList});

  factory DailyScheduleResult.fromJson(Map<String, dynamic> json) {
    return DailyScheduleResult(
      date: json['date'],
      categoryList:
          json['categoryList'] != null
              ? (json['categoryList'] as List)
                  .map((i) => ScheduleCategory.fromJson(i))
                  .toList()
              : [],
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
      id: json['id'],
      categoryName: json['categoryName'],
      color: json['color'],
      scheduleType: json['scheduleType'],
    );
  }
}
