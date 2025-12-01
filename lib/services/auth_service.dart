import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://54.116.11.20:8080';

  // 회원가입
  static Future<String?> signup(String email,
      String password,
      String nickname,) async {
    final url = Uri.parse('$baseUrl/api/member/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nickname': nickname,
        }),
      );

      final decodeBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        print('회원가입 성공');
        return null;
      } else {
        final message = data['message'] ?? '회원가입에 실패했습니다.';
        print('회원가입 실패 : $message');
        return message;
      }
    } catch (e) {
      print('오류 : $e');
      return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }

  // 로그인
  static Future<Map<String, dynamic>?> login(String email,
      String password,) async {
    final url = Uri.parse('$baseUrl/api/member/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final decodeBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        final result = data['result'];
        final tokenData = result['token'];
        final accessToken = tokenData['accessToken'] ?? '';
        final refreshToken = tokenData['refreshToken'] ?? '';

        if (accessToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', accessToken);
          await prefs.setString('refreshToken', refreshToken);
          return result;
        } else {
          print('로그인 실패 : accessToken이 없습니다');
          return null;
        }
      } else {
        print('로그인 실패 : ${data['message']}');
        return null;
      }
    } catch (e) {
      print('오류:$e');
      return null;
    }
  }

  // 액세스 토큰 재발급
  static Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) {
      print('리프레시 토큰 없음');
      return null;
    }

    final url = Uri.parse('$baseUrl/api/member/refresh');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      print('토큰 갱신 상태코드: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('토큰 갱신 실패 (Status: ${response.statusCode})');
        return null;
      }

      if (response.body.isEmpty) {
        print('토큰 갱신 실패: 응답 본문이 비어있습니다.');
        return null;
      }

      final decodeBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      if (data['isSuccess'] == true) {
        final newAccessToken = data['result']['accessToken'];

        await prefs.setString('accessToken', newAccessToken);

        if (data['result']['refreshToken'] != null) {
          await prefs.setString('refreshToken', data['result']['refreshToken']);
        }

        print('토큰 갱신 성공!');
        return newAccessToken;
      } else {
        print('재발급 로직 실패: ${data['message']}');
        return null;
      }
    } catch (e) {
      print('재발급 중 오류 발생: $e');
      return null;
    }
  }
}