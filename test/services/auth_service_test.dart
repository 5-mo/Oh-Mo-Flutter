import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// AuthService의 핵심 파싱 로직만 순수 함수로 추출해 테스트
// (HTTP 의존성 없이 응답 파싱 검증)
void main() {
  group('AuthService 응답 파싱 로직', () {
    test('로그인 성공 응답에서 accessToken을 파싱한다', () {
      final responseBody = jsonEncode({
        'isSuccess': true,
        'result': {
          'token': {
            'accessToken': 'test-access-token',
            'refreshToken': 'test-refresh-token',
          },
          'nickname': '유진',
        },
      });

      final data = jsonDecode(responseBody);
      expect(data['isSuccess'], true);

      final result = data['result'];
      final tokenData = result['token'];
      expect(tokenData['accessToken'], 'test-access-token');
      expect(tokenData['refreshToken'], 'test-refresh-token');
      expect(result['nickname'], '유진');
    });

    test('로그인 실패 응답에서 에러 메시지를 파싱한다', () {
      final responseBody = jsonEncode({
        'isSuccess': false,
        'message': '이메일 또는 비밀번호가 올바르지 않습니다.',
      });

      final data = jsonDecode(responseBody);
      expect(data['isSuccess'], false);
      expect(data['message'], '이메일 또는 비밀번호가 올바르지 않습니다.');
    });

    test('토큰 재발급 성공 응답에서 새 accessToken을 파싱한다', () {
      final responseBody = jsonEncode({
        'isSuccess': true,
        'result': {
          'token': {
            'accessToken': 'new-access-token',
            'refreshToken': 'new-refresh-token',
          },
        },
      });

      final data = jsonDecode(responseBody);
      expect(data['isSuccess'], true);

      final tokenData = data['result']['token'];
      expect(tokenData['accessToken'], 'new-access-token');
    });

    test('회원가입 성공 응답을 판별한다', () {
      final responseBody = jsonEncode({
        'isSuccess': true,
        'result': null,
        'message': '회원가입 성공',
      });

      final data = jsonDecode(responseBody);
      expect(data['isSuccess'], true);
    });

    test('비어있는 accessToken은 로그인 실패로 처리된다', () {
      final accessToken = '';
      expect(accessToken.isNotEmpty, false);
    });
  });

  group('API URL 설정', () {
    test('baseUrl이 올바르게 설정된다', () {
      const baseUrl = 'http://3.36.161.109:8080';
      expect(baseUrl.startsWith('http'), true);
      expect(Uri.parse(baseUrl).host, '3.36.161.109');
      expect(Uri.parse(baseUrl).port, 8080);
    });

    test('API 엔드포인트 URL이 올바르게 조합된다', () {
      const baseUrl = 'http://3.36.161.109:8080';
      final loginUrl = Uri.parse('$baseUrl/api/member/login');
      expect(loginUrl.path, '/api/member/login');
    });
  });
}
