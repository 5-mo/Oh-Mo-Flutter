import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../models/todo.dart';

class TodoService {
  final String baseUrl = 'http://3.36.161.109:8080';

  Future<List<Todo>> getTodos(DateTime date, String token) async {
    final formattedDate = date.toIso8601String().split('T').first;

    final url = Uri.parse('$baseUrl/by-date?date=$formattedDate&type=TO_DO');

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonData['isSuccess'] == true) {
          final results = jsonData['result'];
          if (results is List) {
            return results.map((item) => Todo.fromJson(item)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('투두 조회 에러: $e');
      return [];
    }
  }

  Future<int?> registerTodo({
    required int categoryId,
    String? time,
    bool alarm = false,
    required String content,
    required String date,
  }) async {
    final url = Uri.parse('$baseUrl/todo');
    final Map<String, dynamic> bodyMap = {
      "categoryId": categoryId,
      "time": (time == null || time.isEmpty) ? null : time.substring(0, 5),
      "alarm": alarm,
      "content": content,
      "date": date,
      "routineWeek": [],
    };
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(bodyMap),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['isSuccess'] == true) {
          return jsonResponse['result']['todoId'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateTodo({
    required int scheduleId,
    required int categoryId,
    String? time,
    String? alarmTime,
    required String content,
    required String date,
    List<String>? routineWeek,
  }) async {
    final url = Uri.parse('$baseUrl/$scheduleId/todo');
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "categoryId": categoryId,
            "time": time,
            "alarmTime": alarmTime,
            "content": content,
            "date": date,
            "routineWeek": routineWeek ?? [],
          }),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTodo(int todoId) async {
    final url = Uri.parse('$baseUrl/api/todo/$todoId');
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.delete(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool?> toggleTodoStatus(int todoId) async {
    final url = Uri.parse('$baseUrl/api/todo/$todoId');
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.patch(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
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
      return null;
    }
  }

  Future<List<dynamic>> getTodosByMonth(String yearMonth, String token) async {
    final url = Uri.parse('$baseUrl/by-month?year-month=$yearMonth');
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true) {
          return data['result'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateTodoDate(int scheduleId, String newDate) async {
    final url = Uri.parse('$baseUrl/update-date');
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({"scheduleId": scheduleId, "date": newDate}),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAlarmTime(int scheduleId, String? alarmTimeStr) async {
    final url = Uri.parse('$baseUrl/alarm');
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "scheduleId": scheduleId,
            "alarmTime": alarmTimeStr,
          }),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> registerAiTodo(String text) async {
    final url = Uri.parse('$baseUrl/nlp/todo');

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({"text": text}),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['isSuccess'] == true) {
          return jsonResponse['result'];
        }
      }
      return null;
    } catch (e) {
      print('AI 일정 등록 에러 : $e');
      return null;
    }
  }
}
