import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class TodoService {
  final String baseUrl = 'http://54.116.11.20:8080';

  Future<List<Todo>> getTodos(DateTime date, String token) async {
    final formattedDate = date.toIso8601String().split('T').first;

    final url = Uri.parse(
      '$baseUrl/api/schedule/by-date?date=$formattedDate&type=TO_DO',
    );

    print('투두 요청: $url');

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
    String? time,
    bool alarm = false,
    required String content,
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('[TodoService] 토큰이 없습니다.');
        return false;
      }

      final url = Uri.parse('$baseUrl/api/schedule/todo');

      String? safeTime = time;
      if (time != null && time.length > 5) {
        safeTime = time.substring(0, 5);
      }

      final Map<String, dynamic> bodyMap = {
        "categoryId": categoryId,
        "time": safeTime,
        "alarm": alarm,
        "content": content,
        "date": date,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('[TodoService] 에러 발생: $e');
      return false;
    }
  }

  Future<bool?> toggleTodoStatus(int todoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) return null;

      final url = Uri.parse('$baseUrl/api/todo/$todoId');

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['isSuccess'] == true &&
            jsonResponse['result'] != null) {
          return jsonResponse['result']['status'];
        }
      }
      print('서버 상태 변경 실패: ${response.body}');
      return null;
    } catch (e) {
      print('통신 에러: $e');
      return null;
    }
  }

  Future<List<dynamic>> getTodosByMonth(String yearMonth, String token) async {
    final url = Uri.parse(
      '$baseUrl/api/schedule/by-month?year-month=$yearMonth',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['isSuccess'] == true) {
        return data['result'] as List<dynamic>;
      } else {
        throw Exception('API 실패: ${data['message']}');
      }
    } else {
      throw Exception('HTTP 에러: ${response.statusCode}');
    }
  }

  Future<bool> updateTodoDate(int scheduleId, String newDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) return false;

      final url = Uri.parse('$baseUrl/api/schedule/update-date');

      final Map<String, dynamic> body = {
        "scheduleId": scheduleId,
        "date": newDate,
      };

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] ?? false;
      } else {
        print("날짜 변경 실패 : ${response.body}");
        return false;
      }
    } catch (e) {
      print("통신 에러 : $e");
      return false;
    }
  }

  Future<bool> updateAlarmTime(int scheduleId, String? alarmTimeStr) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) return false;

      final url = Uri.parse('$baseUrl/api/schedule/alarm');

      final Map<String, dynamic> body = {
        "scheduleId": scheduleId,
        "alarmTime": alarmTimeStr,
      };

      print('알람 변경 요청 : $body');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] ?? false;
      } else {
        print("알람 변경 실패 : ${utf8.decode(response.bodyBytes)}");
        return false;
      }
    } catch (e) {
      print("통신 에러 : $e");
      return false;
    }
  }
}
