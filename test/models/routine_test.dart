import 'package:flutter_test/flutter_test.dart';
import 'package:ohmo/models/routine.dart';
import 'package:ohmo/const/colors.dart';

void main() {
  group('Routine.fromJson()', () {
    test('정상적인 JSON에서 Routine 객체를 생성한다', () {
      final json = {
        'scheduleId': 5,
        'content': '아침 스트레칭',
        'category': {'color': 'aquaGreen', 'categoryName': '건강'},
        'date': '2026-04-20',
        'startDate': '2026-01-01',
        'time': '07:00',
        'alarm': true,
        'status': 'DONE',
      };

      final routine = Routine.fromJson(json);

      expect(routine.id, 5);
      expect(routine.content, '아침 스트레칭');
      expect(routine.colorType, ColorType.aquaGreen);
      expect(routine.time, '07:00');
      expect(routine.alarm, true);
      expect(routine.isDone, true);
      expect(routine.daysOfWeek, [1]); // 2026-04-20은 월요일 (weekday=1)
    });

    test('category가 default일 때 uncategorizedBlack 색상으로 파싱된다', () {
      final json = {
        'scheduleId': 6,
        'content': '일기 쓰기',
        'category': {'color': '#000000', 'categoryName': 'default'},
        'date': '2026-04-20',
        'alarm': false,
        'status': 'NOT_DONE',
      };

      final routine = Routine.fromJson(json);

      expect(routine.colorType, ColorType.uncategorizedBlack);
      expect(routine.isDone, false);
    });

    test('status가 bool true일 때 isDone이 true다', () {
      final json = {
        'scheduleId': 7,
        'content': '명상',
        'category': {'color': 'lavender'},
        'date': '2026-04-20',
        'alarm': false,
        'status': 'NOT_DONE',
        'isDone': true,
      };

      final routine = Routine.fromJson(json);

      expect(routine.isDone, true);
    });

    test('startDate가 없을 때 현재 날짜로 설정된다', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));

      final json = {
        'scheduleId': 8,
        'content': '독서',
        'category': {'color': 'pinkLight'},
        'date': '2026-04-20',
        'alarm': false,
        'status': 'NOT_DONE',
      };

      final routine = Routine.fromJson(json);
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(routine.startDate!.isAfter(before), true);
      expect(routine.startDate!.isBefore(after), true);
    });
  });
}
