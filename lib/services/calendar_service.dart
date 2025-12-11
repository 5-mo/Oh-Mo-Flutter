import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/monthly_schedule_response.dart';
import '../models/daily_schedule_response.dart';

class CalendarService {
  static const String baseUrl = 'http://54.116.11.20:8080';

  Future<DailyScheduleResponse> getDailySchedule(
    String date,
    String token,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/api/schedule/by-date',
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
      '$baseUrl/api/schedule/by-month',
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
}
