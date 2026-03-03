import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ohmo/services/auth_service.dart';
import '../models/monthly_schedule_response.dart';
import '../models/daily_schedule_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarService {
  static const String baseUrl = 'http://3.36.161.109:8080';

  Future<DailyScheduleResponse> getDailySchedule(String date) async {
    final uri = Uri.parse(
      '$baseUrl/by-date',
    ).replace(queryParameters: {'date': date});
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return DailyScheduleResponse.fromJson(decoded);
      } else {
        throw Exception('일정 로드 실패 : ${response.statusCode}');
      }
    } catch (e) {
      print("일별 조회 에러 : $e");
      rethrow;
    }
  }

  Future<List<DailyScheduleResult>> getMonthlySchedule(String yearMonth) async {
    final uri = Uri.parse(
      '$baseUrl/by-month',
    ).replace(queryParameters: {'year-month': yearMonth});

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final responseData = MonthlyScheduleResponse.fromJson(decoded);
        return responseData.isSuccess && responseData.result != null
            ? responseData.result!
            : [];
      } else if (response.statusCode == 400) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded['code'] == 'MEMBER_CATEGORY4001') return [];
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print("월별 조회 에러 : $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchSchedules(String query) async {
    final uri = Uri.parse(
      '$baseUrl',
    ).replace(queryParameters: {'query': query});

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        if (decodedData['isSuccess'] == true) {
          final result = decodedData['result'];
          final List<dynamic> todoList = result['todoList'] ?? [];
          final List<dynamic> routineList = result['routineList'] ?? [];

          final Set<String> seenItems = {};
          List<Map<String, dynamic>> combinedResults = [];

          void addIfUnique(dynamic item, String type) {
            final dynamic scheduleId = item['scheduleId'];
            final String content = item['content'] ?? '제목 없음';
            final String date = item['date'] ?? '';
            final String uniqueKey = scheduleId?.toString() ?? '$content-$date';

            if (!seenItems.contains(uniqueKey)) {
              seenItems.add(uniqueKey);
              combinedResults.add({
                'scheduleId': scheduleId,
                'content': content,
                'date': DateTime.parse(date),
                'type': type,
              });
            }
          }

          for (var item in todoList) addIfUnique(item, 'TODO');
          for (var item in routineList) addIfUnique(item, 'ROUTINE');

          return combinedResults;
        }
      }
      return [];
    } catch (e) {
      print("[검색 에러] : $e");
      return [];
    }
  }
}
