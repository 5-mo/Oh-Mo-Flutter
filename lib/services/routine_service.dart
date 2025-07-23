import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';

class RoutineService {
  final String baseUrl = 'http://43.201.188.84:8080';

  Future<List<Routine>> getRoutines(DateTime startDate, DateTime endDate, String token) async {
    final formattedStart = startDate.toIso8601String().split("T").first;
    final formattedEnd = endDate.toIso8601String().split("T").first;

    final url = Uri.parse(
      '$baseUrl/api/schedule/routine/status?start-date=$formattedStart&end-date=$formattedEnd',
    );

    print('루틴 요청 URL: $url');
    print('보내는 날짜 형식 확인: start=$formattedStart, end=$formattedEnd');


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
            final scheduleList = item['scheduleList'];
            if (scheduleList is List) {
              for (var schedule in scheduleList) {
                try {
                  routines.add(Routine.fromJson(schedule));
                } catch (e) {
                  print('루틴 파싱 실패: $e');
                }
              }
            }
          }
        }

        for (var r in routines) {
          print("루틴 내용: ${r.content}, 시작 날짜: ${r.startDate},끝 날짜: ${r.endDate}" );
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
    required bool alarm,
    required String content,
    required String endDate,
    required List<String> routineWeek,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print("토큰 없음");
        return false;
      }

      final url = Uri.parse('$baseUrl/api/schedule/routine');

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
          "endDate": endDate,
          "routineWeek": routineWeek,
        }),
      );

      print('루틴 등록 응답 코드: ${response.statusCode}');
      print('루틴 등록 응답 바디: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('루틴 등록 요청 중 예외 발생: $e');
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
}
