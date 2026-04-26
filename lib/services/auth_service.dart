import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import '../const/app_config.dart';

class AuthService {
  static const String baseUrl = AppConfig.baseUrl;
  static const _storage = FlutterSecureStorage();

  // 회원가입
  static Future<String?> signup(
    String email,
    String password,
    String nickname,
  ) async {
    final url = Uri.parse('$baseUrl/api/member/signup');

    try {
      var request = http.MultipartRequest('POST', url);

      var signupData = jsonEncode({
        'email': email,
        'password': password,
        'nickname': nickname,
      });

      request.files.add(
        http.MultipartFile.fromString(
          'request',
          signupData,
          contentType: MediaType('application', 'json'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('상태 코드 : ${response.statusCode}');
      print('응답 바디 : ${response.body}');

      if (response.body.isEmpty) {
        print('에러: 서버 응답 바디가 완전히 비어있습니다.');
        return '서버에서 빈 응답을 보냈습니다. (상태 코드: ${response.statusCode})';
      }

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
          await _storage.write(key: 'accessToken', value: accessToken);
          await _storage.write(key: 'refreshToken', value: refreshToken);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', email);
          if (result['nickname'] != null) {
            await prefs.setString('userNickname', result['nickname']);
          }
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
    final storedRefreshToken = await _storage.read(key: 'refreshToken');

    if (storedRefreshToken == null) {
      print('리프레시 토큰 없음');
      return null;
    }

    final url = Uri.parse('$baseUrl/api/member/reissue');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': storedRefreshToken}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodeBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodeBody);

        if (data['isSuccess'] == true) {
          final tokenData = data['result']['token'];
          final newAccessToken = tokenData['accessToken'];
          final newRefreshToken = tokenData['refreshToken'];

          await _storage.write(key: 'accessToken', value: newAccessToken);

          if (newRefreshToken != null) {
            await _storage.write(key: 'refreshToken', value: newRefreshToken);
          }
          print('토큰 재발급 성공!');
          return newAccessToken;
        } else {
          print('재발급 로직 실패 : ${data['message']}');
          return null;
        }
      } else {
        print('토큰 갱신 실패(Status : ${response.statusCode})');
        return null;
      }
    } catch (e) {
      print('재발급 중 오류 발생 : $e');
      return null;
    }
  }

  //로그아웃
  static Future<bool> logout() async {
    final accessToken = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$baseUrl/api/member/logout');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 3));

      final decodeBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'refreshToken');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userEmail');
      await prefs.remove('userNickname');

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        print('서버 로그아웃 성공');
        return true;
      } else {
        print('서버 로그아웃 실패 : ${data['message']}');
        return false;
      }
    } catch (e) {
      print('로그아웃 중 오류 발생 : $e');
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'refreshToken');
      return false;
    }
  }

  // 회원탈퇴
  static Future<bool> withdraw() async {
    final accessToken = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$baseUrl/api/member/withdraw');

    try {
      final response = await http
          .delete(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 5));

      print('탈퇴 API 응답 코드: ${response.statusCode}');
      print('탈퇴 API 응답 바디: ${response.body}');

      final decodeBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        print('회원 탈퇴 성공');
        await _storage.delete(key: 'accessToken');
        await _storage.delete(key: 'refreshToken');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('userEmail');
        await prefs.remove('userNickname');
        return true;
      } else {
        print('회원 탈퇴 실패 : ${data['message']}');
        return false;
      }
    } catch (e) {
      print('회원 탈퇴 중 오류 발생 : $e');
      return false;
    }
  }

  //비밀번호 변경
  static Future<String?> updatePassword(
    String oldPassword,
    String newPassword,
  ) async {
    final accessToken = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$baseUrl/api/member/password');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      final decodeBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        print("비밀번호 변경 성공");
        return null;
      } else {
        final message = data['message'] ?? '비밀번호 변경에 실패했습니다';
        print('비밀번호 변경 실패 : $message');
        return message;
      }
    } catch (e) {
      print('비밀번호 변경 중 오류 발생 : $e');
      return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }

  static Future<http.Response> authenticatedRequest(
    Future<http.Response> Function(String token) requestFn,
  ) async {
    String? token = await _storage.read(key: 'accessToken');

    var response = await requestFn(token ?? '');

    if (response.statusCode == 401) {
      print("토큰 만료됨. 재발급 시도");
      final newToken = await refreshToken();

      if (newToken != null) {
        print("토큰 재발급 성공, 재요청 진행");
        response = await requestFn(newToken);
      }
    }

    return response;
  }

  static Future<String?> sendResetCode(String email) async {
    final url = Uri.parse('$baseUrl/api/member/password/find');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final decodeBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        print('인증 코드 발송 성공');
        return null;
      } else {
        final message = data['message'] ?? '인증 코드 발송에 실패했습니다.';
        print('인증 코드 발송 실패 : $message');
        return message;
      }
    } catch (e) {
      print('인증 코드 발송 중 오류 발생 : $e');
      return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }

  static Future<String?> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    final url = Uri.parse('$baseUrl/api/member/password/reset');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      final decodeBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodeBody);

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        print('비밀번호 재설정 성공');
        return null;
      } else {
        final message = data['message'] ?? '비밀번호 재설정에 실패했습니다.';
        print('비밀번호 재설정 실패 : $message');
        return message;
      }
    } catch (e) {
      print('비밀번호 재설정 중 오류 발생 : $e');
      return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }
}
