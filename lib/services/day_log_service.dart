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

  Future<bool> registerQuestion({
    required String questionContent,
    required String emoji,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('[DayLogService] 토큰이 없습니다.');
        return false;
      }
      final url = Uri.parse('$baseUrl/api/question');

      final Map<String, dynamic> bodyMap = {
        "questionContent": questionContent,
        "emoji": emoji,
      };

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
        print('[DayLogService] 서버 에러 : ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('[DayLogService] 통신 오류 : $e');
      return false;
    }
  }

  Future<List<dynamic>?> getQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('[DayLogService] 토큰이 없습니다.');
        return null;
      }

      final url = Uri.parse('$baseUrl/api/question');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        if (jsonResponse['isSuccess'] == true) {
          return jsonResponse['result'];
        } else {
          print('[DayLogService] 서버 응답 실패: ${jsonResponse['message']}');
          return null;
        }
      } else {
        print('[DayLogService] 서버 에러 : ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[DayLogService] 통신 오류 : $e');
      return null;
    }
  }

  Future<bool> registerAnswer({
    required int questionId,
    required String answer,
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) return false;

      final url = Uri.parse('$baseUrl/api/answer');
      final Map<String, dynamic> bodyMap = {
        "questionId": questionId,
        "answer": answer,
        "date": date,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyMap),
      );

      print(
        '[registerAnswer] Status: ${response.statusCode}, Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('[registerAnswer] Error: $e');
      return false;
    }
  }

  Future<List<dynamic>?> getQuestionAnswers(String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) return null;

      final url = Uri.parse('$baseUrl/api/question/answer?date=$date');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        if (jsonResponse['isSuccess'] == true) {
          return jsonResponse['result'];
        }
      }
      return null;
    } catch (e) {
      print('[DayLogService 조회 오류 : $e');
      return null;
    }
  }

  Future<bool> registerDiary({
    required String content,
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('[DayLogService] 토큰이 없습니다.');
        return false;
      }
      final url = Uri.parse('$baseUrl/api/diary');
      final Map<String, dynamic> bodyMap = {"content": content, "date": date};

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyMap),
      );
      print(
        '[registerDiary] Status: ${response.statusCode},Body:${response.body}',
      );

      if (response.statusCode == 200) {
        final jsonREsponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonREsponse['isSuccess'] == true;
      } else {
        print('[DayLogService] 서버 에러 : ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('[DayLogService] 일기 등록 통신 오류 : $e');
      return false;
    }
  }
}
