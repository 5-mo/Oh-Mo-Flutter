import 'package:flutter_test/flutter_test.dart';
import 'package:ohmo/models/todo.dart';
import 'package:ohmo/const/colors.dart';

void main() {
  group('Todo.fromJson()', () {
    test('정상적인 JSON에서 Todo 객체를 생성한다', () {
      final json = {
        'scheduleId': 1,
        'todoId': 10,
        'content': '운동하기',
        'category': {'color': 'pinkLight'},
        'date': '2026-04-20',
        'time': '09:00',
        'alarm': true,
        'status': false,
      };

      final todo = Todo.fromJson(json);

      expect(todo.id, 1);
      expect(todo.scheduleId, 10);
      expect(todo.content, '운동하기');
      expect(todo.colorType, ColorType.pinkLight);
      expect(todo.Date, DateTime(2026, 4, 20));
      expect(todo.time, '09:00');
      expect(todo.alarm, true);
      expect(todo.isDone, false);
    });

    test('category 없을 때 기본 색상(pinkLight)으로 파싱된다', () {
      final json = {
        'scheduleId': 2,
        'content': '책 읽기',
        'category': {},
        'date': '2026-04-20',
        'alarm': false,
        'status': true,
      };

      final todo = Todo.fromJson(json);

      expect(todo.colorType, ColorType.pinkLight);
      expect(todo.isDone, true);
    });

    test('scheduleId 없을 때 id가 0으로 파싱된다', () {
      final json = {
        'content': '물 마시기',
        'category': {'color': 'skyBlue'},
        'date': '2026-04-20',
        'alarm': false,
        'status': false,
      };

      final todo = Todo.fromJson(json);

      expect(todo.id, 0);
      expect(todo.colorType, ColorType.skyBlue);
    });
  });

  group('Todo.toJson()', () {
    test('Todo 객체를 JSON으로 직렬화한다', () {
      final todo = Todo(
        id: 1,
        content: '운동하기',
        colorType: ColorType.pinkLight,
        Date: DateTime(2026, 4, 20),
        time: '09:00',
        alarm: true,
        isDone: false,
      );

      final json = todo.toJson();

      expect(json['id'], 1);
      expect(json['content'], '운동하기');
      expect(json['alarm'], true);
      expect(json['isDone'], false);
    });
  });
}
