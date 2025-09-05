import 'package:uuid/uuid.dart';

import 'const/colors.dart';

class ICategoryItem {
  final String id;
  String content;
  ColorType colorType;

  ICategoryItem({required this.id, required this.content,this.colorType=ColorType.pinkLight});
}

var uuid = Uuid();

List<ICategoryItem> daylogQuestions = [
  ICategoryItem(id: uuid.v4(), content: '💰 오늘의 소비는?'),
  ICategoryItem(id: uuid.v4(), content: '😊 오늘의 내가 감사했던 일은?'),
];
