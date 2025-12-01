import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';

class RoutineService {
  final String baseUrl = 'http://54.116.11.20:8080';

  Future<List<Routine>> getRoutines(DateTime date, String token) async {
    final formattedDate = date.toIso8601String().split('T').first;

    final url = Uri.parse(
      '$baseUrl/api/schedule/by-date?date=$formattedDate&type=ROUTINE',
    );

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

  Future<bool> registerRoutine({
    required int categoryId,
    required String time,
    required String? alarmTime,
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

      final url = Uri.parse('$baseUrl/api/schedule/routine');

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
      print('[RoutineService] 에러 발생: $e');
      return false;
    }
  }

  Future<void> toggleRoutineStatus(int scheduleId) async {
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

  Future<List<dynamic>> getRoutinesByMonth(
    String yearMonth,
    String token,
  ) async {
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
}
