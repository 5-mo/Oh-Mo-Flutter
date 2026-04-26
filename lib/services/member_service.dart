import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import '../const/app_config.dart';
import 'auth_service.dart';

class MemberService {
  final String baseUrl = AppConfig.baseUrl;
  static const _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>?> fetchUserInfo() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      final response = await http.get(
        Uri.parse('$baseUrl/api/member'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        if (responseData['isSuccess'] == true) {
          return responseData['result'];
        } else {
          print("서버 에러 : ${response.statusCode}");
          return null;
        }
      } else {
        print("서버 에러 : ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("네트워크 에러 : $e");
      return null;
    }
  }

  Future<bool> updateNickname(String newNickname) async {
    try {
      final token = await _storage.read(key: 'accessToken');

      final response = await http.patch(
        Uri.parse('$baseUrl/api/member/nickname'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nickname': newNickname}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        if (responseData['isSuccess'] == true) {
          print("닉네임 수정 성공 : ${responseData['result']['nickname']}");
          return true;
        } else {
          print("수정 실패 : ${responseData['message']}");
          return false;
        }
      } else {
        print("서버 에러 : ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("네트워크 에러 : $e");
      return false;
    }
  }

  Future<bool> updateProfileImage(File imageFile) async {
    String? token = await _storage.read(key: 'accessToken');
    final result = await _sendImageRequest(imageFile, token);

    if (result == 401 || result == 403) {
      final newToken = await AuthService.refreshToken();
      if (newToken != null) {
        final retryResult = await _sendImageRequest(imageFile, newToken);
        return retryResult == 200;
      }
      return false;
    }
    return result == 200;
  }

  Future<int> _sendImageRequest(File imageFile, String? token) async {
    final url = Uri.parse('$baseUrl/api/member/profile-image');

    try {
      String extension = p
          .extension(imageFile.path)
          .toLowerCase()
          .replaceFirst('.', '');
      String subtype =
          (extension == 'jpg' || extension == 'jpeg') ? 'jpeg' : extension;

      var request = http.MultipartRequest('PATCH', url);
      request.headers['Authorization'] = 'Bearer ${token?.trim()}';
      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          imageFile.path,
          contentType: MediaType('image', subtype),
        ),
      );

      print("이미지 업로드 시도: ${imageFile.path} (type: $subtype)");
      print("Authorization 헤더: Bearer ${token?.trim().substring(0, 20)}...");
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("프로필 이미지 수정 성공");
      } else {
        print("프로필 이미지 수정 실패 : ${response.statusCode}");
        print("응답 헤더: ${response.headers}");
        print("응답 바디: $responseBody");
      }
      return response.statusCode;
    } catch (e) {
      print("프로필 이미지 수정 중 오류 발생 : $e");
      return 500;
    }
  }

  Future<bool> updateFcmToken(String fcmToken) async {
    final url = Uri.parse('$baseUrl/api/member/fcm-token');

    try {
      final token = await _storage.read(key: 'accessToken');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print("FCM 토큰 등록 에러 : $e");
      return false;
    }
  }
}
