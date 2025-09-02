import 'package:flutter/foundation.dart';

class CategoryItem {
  final int id;
  late final String categoryName;
  final String colorType;
  final String scheduleType;

  CategoryItem({
    required this.id,
    required this.categoryName,
    required this.colorType,
    required this.scheduleType,
  });
}

class DayLogQuestionItem {
  final int id;
  final String question;
  final String emoji;

  DayLogQuestionItem({
    required this.id,
    required this.question,
    required this.emoji,
  });
}
