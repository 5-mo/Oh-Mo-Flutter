import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DayLogService {
  final String baseUrl = 'http://54.116.11.20:8080';

  Future<bool> registerEmoji({
    required String date,
    required String emoji,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('[DayLogService] 토큰이 없습니다.');
        return false;
      }

      final url = Uri.parse('$baseUrl/api/day-log/emoji');

      final Map<String, dynamic> bodyMap = {"date": date, "emoji": emoji};

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('[통신 오류]$e');
      return false;
    }
  }
}
