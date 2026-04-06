import 'package:flutter/foundation.dart';

class CategoryItem {
  final int id;
  final int? serverId;
  String categoryName;
  String colorType;
  String scheduleType;
  final bool isSynced;

  CategoryItem({
    required this.id,
    this.serverId,
    required this.categoryName,
    required this.colorType,
    required this.scheduleType,
    this.isSynced = false,
  });
}

class DayLogQuestionItem {
  final int id;
  final String question;
  final String emoji;
  final int? serverId;

  DayLogQuestionItem({
    required this.id,
    required this.question,
    required this.emoji,
    this.serverId,
  });
}
