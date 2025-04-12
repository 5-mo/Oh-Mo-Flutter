import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<String?> signup(String email, String password,
      String nickname) async {
    final url = Uri.parse('http://43.200.252.22:8080/api/member/signup');

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

      final decodeBody=utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      if (response.statusCode == 200 && data['isSuccess']==true) {
        print('회원가입 성공');
        return null;
      } else {
        final message=data['message'] ?? '회원가입에 실패했습니다.';
        print('회원가입 실패 : $message');
        return message;
      }
    } catch (e) {
      print('오류 : $e');
      return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }
  static Future<Map<String,dynamic>?> login(String email, String password) async {
    final url = Uri.parse('http://43.200.252.22:8080/api/member/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final decodeBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      if (response.statusCode == 200&&data['isSuccess']==true) {
        print('로그인 성공 : ${data['result']}');
        return data['result'];
      } else {
    final message=data['message'] ?? '로그인에 실패했습니다.';
    print('로그인 실패 : $message');
    return null;
    }
    }
    catch(e){
      print('오류:$e');
      return null;
    }
  }
}