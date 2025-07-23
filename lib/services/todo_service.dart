import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class TodoService {
  final String baseUrl = 'http://43.201.188.84:8080';

  Future<List<Todo>> getTodos(DateTime date, String token) async {
    final formattedDate = date.toIso8601String().split('T').first;

    final url = Uri.parse(
      'http://43.201.188.84:8080/api/schedule/by-date'
          '?date=$formattedDate&type=TO_DO',
    );

    print('투두 요청 날짜: $formattedDate');
    print('보내는 URL: $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonData['isSuccess'] == true) {
        final List<Todo> todos = [];
        final results = jsonData['result'];
        if (results is List) {
          for (var item in results) {
            try {
              todos.add(Todo.fromJson(item));
            } catch (e) {
              print('투두 파싱 실패: $e');
            }
          }
        }
        return todos;
      } else {
        throw Exception('API 실패: ${jsonData['message']}');
      }
    } else {
      throw Exception('서버 응답 오류: ${response.statusCode}');
    }
  }

  Future<bool> registerTodo({
    required int categoryId,
    required String time,
    required bool alarm,
    required String content,
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print("토큰 없음");
        return false;
      }

      final url = Uri.parse('$baseUrl/api/schedule/todo');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "categoryId": categoryId,
          "time": time,
          "alarm": alarm,
          "content": content,
          "date": date,
        }),
      );

      print('투두 등록 응답 코드: ${response.statusCode}');
      print('투두 등록 응답 바디: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('투두 등록 요청 중 예외 발생: $e');
      return false;
    }
  }

  Future<void> toggleTodoStatus(int scheduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final url = Uri.parse('$baseUrl/api/schedule/$scheduleId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('상태 변경 실패: ${response.statusCode}');
    }
  }
}
