import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

import 'const/colors.dart';

class ICategoryItem {
  final String id;
  String content;
  ColorType colorType;

  ICategoryItem({required this.id, required this.content,this.colorType=ColorType.pinkLight});
}

var uuid = Uuid();

List<ICategoryItem> routines = [
  ICategoryItem(id: uuid.v4(), content: '오모 회의'),
  ICategoryItem(id: uuid.v4(), content: '데이트'),
];

List<ICategoryItem> todos = [
  ICategoryItem(id: uuid.v4(), content: '오모 회의'),
  ICategoryItem(id: uuid.v4(), content: '데이트'),
];
String getTodayDateKey(){
  final now=DateTime.now();
  return "${now.year.toString().padLeft(4,'0')}-"
      "${now.month.toString().padLeft(2,'0')}-"
      "${now.day.toString().padLeft(2,'0')}";
}

Future<void> saveMultipleDays(Map<String,List<ICategoryItem>> itemsByDate) async{
  final prefs=await SharedPreferences.getInstance();

 Map<String,List<String>> encoded={
   for(var entry in itemsByDate.entries)
     entry.key:entry.value.map((e)=>e.content).toList()
 };

  final jsonString=jsonEncode(encoded);
  await prefs.setString('calendar_events',jsonString);

  await HomeWidget.saveWidgetData('calendar_events', jsonString);

  await HomeWidget.updateWidget(
    name: 'HomeWidgetExtension',
    iOSName: 'HomeWidgetExtension',
  );

  await HomeWidget.updateWidget(
    name: 'TodayWidgetExtension',
    iOSName: 'TodayWidgetExtension',
  );
}

//for test
void testCalendarEventSave() async {
  final today = getTodayDateKey();
  final tomorrow = DateTime.now().add(Duration(days: 1));
  final tomorrowKey =
      "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";

  await saveMultipleDays({
    today: [
      ICategoryItem(id: '1', content: '위젯 회의'),
      ICategoryItem(id: '2', content: '개발 일정'),
    ],
    tomorrowKey: [
      ICategoryItem(id: '3', content: '미팅'),
      ICategoryItem(id: '4', content: '헬스장'),
    ],
  });
}


List<ICategoryItem> daylogQuestions = [
  ICategoryItem(id: uuid.v4(), content: '💰 오늘의 소비는?'),
  ICategoryItem(id: uuid.v4(), content: '😊 오늘의 내가 감사했던 일은?'),
];
