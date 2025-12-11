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

  Future<int?> registerRoutine({
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
        return null;
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

      print("URL: $url");
      print("Body: $bodyMap");

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
        print("Response Body: $jsonResponse");

        if (jsonResponse['isSuccess'] == true) {
          final result = jsonResponse['result'];

          if (result is int) {
            return result;
          }
          else if (result is List && result.isNotEmpty) {
            final firstItem = result[0];
            if (firstItem is Map) {
              return firstItem['routineId'] ?? firstItem['id'];
            }
          }
          else if (result is Map) {
            return result['routineId'] ?? result['id'];
          }

          print("서버 응답에서 ID를 찾을 수 없음: $result");
          return null;
        }
        return null;
      }  else {
        print("서버 에러 발생: ${utf8.decode(response.bodyBytes)}");
        return null;
      }
    } catch (e) {
      print('[RoutineService] 통신 에러 발생: $e');
      return null;
    }
  }

  // [수정 포인트 1] 반환 타입을 Future<bool> -> Future<bool?> 로 변경
  // true: 완료됨, false: 미완료됨, null: 에러
  Future<bool?> toggleRoutineStatus(int routineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('[RoutineService] ❌ 토큰이 없습니다.');
        return null; // 실패 시 null 반환
      }

      final url = Uri.parse('$baseUrl/api/routine/$routineId');

      print('🚀 [API 요청] 루틴 상태 변경 시도');
      print('   - Target URL: $url');
      print('   - Routine ID: $routineId');

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 [API 응답] Status: ${response.statusCode}');
      print('   - Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        // [수정 포인트 2] 성공 여부가 아니라, 결과값(result) 안의 'status'를 반환
        if (jsonResponse['isSuccess'] == true && jsonResponse['result'] != null) {
          // 서버가 알려준 진짜 상태 (true or false)를 리턴
          return jsonResponse['result']['status'];
        }
        return null; // 성공 플래그가 false면 null 반환
      } else {
        print('❌ [API 실패] 상태코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ [API 에러] 통신 오류: $e');
      return null;
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
