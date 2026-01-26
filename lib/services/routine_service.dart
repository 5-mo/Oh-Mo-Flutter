import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';

class RoutineService {
  final String baseUrl = 'http://52.79.75.26:8080';

  Future<List<Routine>> getRoutines(DateTime date, String token) async {
    final formattedDate = date.toIso8601String().split('T').first;

    final url = Uri.parse('$baseUrl/by-date?date=$formattedDate&type=ROUTINE');

    print('루틴 요청: $url');

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
        final List<Routine> routines = [];
        final results = jsonData['result'];
        if (results is List) {
          for (var item in results) {
            try {
              routines.add(Routine.fromJson(item));
            } catch (e) {
              print('루틴 파싱 실패: $e');
            }
          }
        }
        return routines;
      } else {
        throw Exception('API 실패: ${jsonData['message']}');
      }
    } else {
      throw Exception('서버 응답 오류: ${response.statusCode}');
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print('[RoutineService] 토큰이 없습니다.');
      return null;
    }

    final url = Uri.parse('$baseUrl/routine');

    String safeTime = time;
    if (time.length > 5) {
      safeTime = time.substring(0, 5);
    }

    final response = await http.post(
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
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['isSuccess'] == true) {
        final result = jsonResponse['result'];
        if (result is List && result.isNotEmpty) {
          return {
            'routineId': result[0]['routineId'],
            'scheduleId': result[0]['scheduleId'],
          };
        }
      }
    }
    return null;
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('[RoutineService] 토큰이 없습니다.');
        return false;
      }
      final url = Uri.parse('$baseUrl/$scheduleId/routine');
      print('실제 요청 URL: $url');

      String safeTime = time;
      if (time.length > 5) {
        safeTime = time.substring(0, 5);
      }
      final Map<String, dynamic> bodyMap = {
        "categoryId": categoryId,
        "time": safeTime,
        "alarmTime": alarmTime,
        "content": content,
        "date": date,
        "routineWeek": routineWeek,
      };

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyMap),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] == true;
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print("서버 수정 실패 상세: [${response.statusCode}] $errorBody");
        return false;
      }
    } catch (e) {
      print('[RoutineService] 수정 중 통신 에러 : $e');
      return false;
    }
  }

  Future<bool> deleteRoutine(int routineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) return false;

      final url = Uri.parse('$baseUrl/api/routine/$routineId');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] == true;
      } else {
        print(
          "서버 삭제 실패 : [${response.statusCode}] ${utf8.decode(response.bodyBytes)}",
        );
        return false;
      }
    } catch (e) {
      print('[RoutineService] 삭제 중 에러 : $e');
      return false;
    }
  }

  Future<bool?> toggleRoutineStatus(int routineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('[RoutineService] 토큰이 없습니다.');
        return null;
      }

      final url = Uri.parse('$baseUrl/api/routine/$routineId');

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
        return null;
      } else {
        print('[API 실패] 상태코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[API 에러] 통신 오류: $e');
      return null;
    }
  }

  Future<List<dynamic>> getRoutinesByMonth(
    String yearMonth,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/by-month?year-month=$yearMonth');

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
}
