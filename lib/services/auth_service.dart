import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
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

        if (accessToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', accessToken);
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
}
