import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../models/routine.dart';

class RoutineService {
  final String baseUrl = 'http://52.79.75.26:8080';

  Future<List<Routine>> getRoutines(DateTime date, String token) async {
    final formattedDate = date.toIso8601String().split('T').first;
    final url = Uri.parse('$baseUrl/by-date?date=$formattedDate&type=ROUTINE');
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
            return results.map((item) => Routine.fromJson(item)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('루틴 조회 에러: $e');
      return [];
    }
  }

  Future<Map<String, int?>?> registerRoutine({
    required int categoryId,
    required String time,
    required String? alarmTime,
    required String content,
    required String date,
    required List<String> routineWeek,
    required String color,
  }) async {
    final url = Uri.parse('$baseUrl/routine');
    String safeTime = time;
    if (time.length > 5) {
      safeTime = time.substring(0, 5);
    }
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "categoryId": categoryId,
            "time": safeTime,
            "alarmTime": alarmTime,
            "content": content,
            "date": date,
            "routineWeek": routineWeek,
            "color": color,
          }),
        ),
      );

      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        final result = jsonResponse['result'];
        if (result is List && result.isNotEmpty) {
          return {
            'routineId': result[0]['routineId'],
            'scheduleId': result[0]['scheduleId'],
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateRoutine({
    required int scheduleId,
    required int categoryId,
    required String time,
    String? alarmTime,
    required String content,
    required String date,
    required List<String> routineWeek,
  }) async {
    final url = Uri.parse('$baseUrl/$scheduleId/routine');
    String safeTime = time;
    if (time.length > 5) {
      safeTime = time.substring(0, 5);
    }
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
            "time": safeTime,
            "alarmTime": alarmTime,
            "content": content,
            "date": date,
            "routineWeek": routineWeek,
          }),
        ),
      );
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return response.statusCode == 200 && jsonResponse['isSuccess'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRoutine(int routineId) async {
    final url = Uri.parse('$baseUrl/api/routine/$routineId');
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
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return response.statusCode == 200 && jsonResponse['isSuccess'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool?> toggleRoutineStatus(int routineId) async {
    final url = Uri.parse('$baseUrl/api/routine/$routineId');
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
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        return jsonResponse['result']['status'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getRoutinesByMonth(
    String yearMonth,
    String token,
  ) async {
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
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && data['isSuccess'] == true) {
        return data['result'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
