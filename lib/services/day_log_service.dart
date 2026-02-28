import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class DayLogService {
  final String baseUrl = 'http://52.79.75.26:8080';

  Future<bool> registerEmoji({
    required String date,
    required String emoji,
  }) async {
    final url = Uri.parse('$baseUrl/api/day-log/emoji');
    final Map<String, dynamic> bodyMap = {"date": date, "emoji": emoji};

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(bodyMap),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('[이모지 등록 오류]$e');
      return false;
    }
  }

  Future<String?> getEmoji(String date) async {
    final url = Uri.parse('$baseUrl/api/day-log/emoji?date=$date');
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
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['isSuccess'] == true &&
            jsonResponse['result'] != null) {
          return jsonResponse['result']['emoji'];
        }
      }
      return null;
    } catch (e) {
      print('이모지 조회 오류 : $e');
      return null;
    }
  }

  Future<dynamic> registerQuestion({
    required String questionContent,
    required String emoji,
  }) async {
    final url = Uri.parse('$baseUrl/api/question');
    final Map<String, dynamic> bodyMap = {
      "questionContent": questionContent,
      "emoji": emoji,
    };
    try {
      final response = await AuthService.authenticatedRequest(
            (token) => http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(bodyMap),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        print('Register Question Response Body: $jsonResponse');

        if (jsonResponse['isSuccess'] == true) {
          return jsonResponse['result'] ?? jsonResponse;
        }
      }
      return null;
    } catch (e) {
      print('질문 등록 오류: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getQuestions() async {
    final url = Uri.parse('$baseUrl/api/question');
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
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['isSuccess'] == true) {
          return jsonResponse['result'];
        }
      }
      return null;
    } catch (e) {
      print('질문 목록 조회 오류: $e');
      return null;
    }
  }

  Future<bool> registerAnswer({
    required int questionId,
    required String answer,
    required String date,
  }) async {
    final url = Uri.parse('$baseUrl/api/answer');
    final Map<String, dynamic> bodyMap = {
      "questionId": questionId,
      "answer": answer,
      "date": date,
    };
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(bodyMap),
        ),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('답변 등록 오류: $e');
      return false;
    }
  }

  Future<List<dynamic>?> getQuestionAnswers(String date) async {
    final url = Uri.parse('$baseUrl/api/question/answer?date=$date');
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
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['isSuccess'] == true) {
          return jsonResponse['result'];
        }
      }
      return null;
    } catch (e) {
      print('[문답 조회 오류 : $e');
      return null;
    }
  }
  Future<dynamic> updateQuestion({
    required int questionId,
    required String questionContent,
    required String emoji,
  }) async {
    final url = Uri.parse('$baseUrl/api/question/$questionId');
    final Map<String, dynamic> bodyMap = {
      "questionContent": questionContent,
      "emoji": emoji,
    };

    try {
      final response = await AuthService.authenticatedRequest(
            (token) => http.patch(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(bodyMap),
        ),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['isSuccess'] == true) {
          return jsonResponse['result'] ?? jsonResponse;
        }
      }
      return null;
    } catch (e) {
      print('질문 수정 오류: $e');
      return null;
    }
  }

  Future<bool> deleteQuestion(int questionId) async {
    final url = Uri.parse('$baseUrl/api/question/$questionId');
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

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('질문 삭제 오류 : $e');
      return false;
    }
  }

  Future<bool> registerDiary({
    required String content,
    required String date,
  }) async {
    final url = Uri.parse('$baseUrl/api/diary');
    final Map<String, dynamic> bodyMap = {"content": content, "date": date};
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(bodyMap),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('일기 등록 오류: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDiary(String date) async {
    final url = Uri.parse('$baseUrl/api/diary?date=$date');
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
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['isSuccess'] == true) {
          return jsonResponse['result'];
        }
      }
      return null;
    } catch (e) {
      print('일기 조회 오류 : $e');
      return null;
    }
  }
}
