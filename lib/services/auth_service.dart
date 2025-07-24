import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 회원가입
  static Future<String?> signup(
      String email,
      String password,
      String nickname,
      ) async {
    final url = Uri.parse('http://43.201.188.84:8080/api/member/signup');

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
  static Future<Map<String, dynamic>?> login(
      String email,
      String password,
      ) async {
    final url = Uri.parse('http://43.201.188.84:8080/api/member/login');

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
          print('로그인 성공 : $accessToken');
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

    final url = Uri.parse('http://43.201.188.84:8080/api/member/refresh'); // ✅ 실제 엔드포인트 확인

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      final decodeBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        final newAccessToken = data['result']['accessToken'];
        await prefs.setString('accessToken', newAccessToken);
        print('액세스 토큰 재발급 성공: $newAccessToken');
        return newAccessToken;
      } else {
        print('재발급 실패: ${data['message']}');
        return null;
      }
    } catch (e) {
      print('재발급 중 오류: $e');
      return null;
    }
  }
}
