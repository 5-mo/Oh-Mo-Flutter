import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class MemberService {
  final String baseUrl = "http://3.36.161.109:8080";

  Future<Map<String, dynamic>?> fetchUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

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
    final url = Uri.parse('$baseUrl/api/member/profile-image');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      var request = http.MultipartRequest('PATCH', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      });

      String extension = p
          .extension(imageFile.path)
          .toLowerCase()
          .replaceFirst('.', '');
      String type = 'image';
      String subtype =
          (extension == 'jpg' || extension == 'jpeg') ? 'jpeg' : extension;

      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          imageFile.path,
          contentType: MediaType(type, subtype),
        ),
      );

      print("이미지 업로드 시도: ${imageFile.path} (type: $subtype)");
      var response = await request.send();

      if (response.statusCode == 200) {
        print("프로필 이미지 수정 성공");
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        print("프로필 이미지 수정 실패 : ${response.statusCode}, $responseBody");
        return false;
      }
    } catch (e) {
      print("프로필 이미지 수정 중 오류 발생 : $e");
      return false;
    }
  }

  Future<bool> updateFcmToken(String fcmToken) async {
    final url = Uri.parse('$baseUrl/api/member/fcm-token');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

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
