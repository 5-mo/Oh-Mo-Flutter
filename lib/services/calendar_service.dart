import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/monthly_schedule_response.dart';
import '../models/daily_schedule_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarService {
  static const String baseUrl = 'http://54.116.11.20:8080';

  Future<DailyScheduleResponse> getDailySchedule(
    String date,
    String token,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/by-date',
    ).replace(queryParameters: {'date': date});
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return DailyScheduleResponse.fromJson(decoded);
      } else {
        throw Exception(
          'Failed to load daily schedule : ${response.statusCode}',
        );
      }
    } catch (e) {
      print("일별 조회 에러 : $e");
      rethrow;
    }
  }

  Future<List<DailyScheduleResult>> getMonthlySchedule(
    String yearMonth,
    String token,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/by-month',
    ).replace(queryParameters: {'year-month': yearMonth});

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final responseData = MonthlyScheduleResponse.fromJson(decoded);

        if (responseData.isSuccess && responseData.result != null) {
          return responseData.result!;
        } else {
          return [];
        }
      } else if (response.statusCode == 400) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        if (decoded['code'] == 'MEMBER_CATEGORY4001') {
          print('신규 유저(카테고리 없음) 감지: 빈 스케줄로 처리합니다.');
          return [];
        }

        print('Network Error : ${response.statusCode}');
        print('Error Body : $decoded');
        return [];
      } else {
        print('Network Error : ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("Exception:$e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchSchedules(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');

      if (token == null) {
        print("토큰이 없어 검색을 진행할 수 없습니다.");
        return [];
      }
      final response = await http.get(
        Uri.parse('$baseUrl?query=$query'),
        headers: {
          'Authorization':'Bearer $token',
          "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));

        if (decodedData['isSuccess'] == true) {
          final result = decodedData['result'];
          final List<dynamic> todoList = result['todoList'] ?? [];
          final List<dynamic> routineList = result['routineList'] ?? [];

          List<Map<String, dynamic>> combinedResults = [];

          for (var item in todoList) {
            combinedResults.add({
              'content': item['content'],
              'date': DateTime.parse(item['date']),
              'type': 'TODO',
            });
          }
          for (var item in routineList) {
            combinedResults.add({
              'content': item['content'],
              'date': DateTime.parse(item['date']),
              'type': 'ROUTINE',
            });
          }
          return combinedResults;
        }
      }
      return [];
    } catch (e) {
      print("ScheduleService 에러 : $e");
      return [];
    }
  }
}
