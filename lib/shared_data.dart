import 'package:uuid/uuid.dart';

class CategoryItem {
  final String id;
  String content;

  CategoryItem({required this.id, required this.content});
}

var uuid = Uuid();

List<CategoryItem> routines = [
  CategoryItem(id: uuid.v4(), content: '오모 회의'),
  CategoryItem(id: uuid.v4(), content: '데이트'),
];

List<CategoryItem> todos = [
  CategoryItem(id: uuid.v4(), content: '코딩하기'),
  CategoryItem(id: uuid.v4(), content: '회의'),
  CategoryItem(id: uuid.v4(), content: '코딩하기'),
  CategoryItem(id: uuid.v4(), content: '회의'),
  CategoryItem(id: uuid.v4(), content: '코딩하기'),
  CategoryItem(id: uuid.v4(), content: '회의'),
  CategoryItem(id: uuid.v4(), content: '코딩하기'),
  CategoryItem(id: uuid.v4(), content: '회의'),
];

List<CategoryItem> daylogQuestions = [
  CategoryItem(id: uuid.v4(), content: '💰 오늘의 소비는?'),
  CategoryItem(id: uuid.v4(), content: '😊 오늘의 내가 감사했던 일은?'),
];
