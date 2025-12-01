import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupService {
  static const String baseUrl = 'http://54.116.11.20:8080/api';

  Future<int> createGroup({
    required String groupName,
    required String password,
    required String groupColor,
    required int memberCount,
    required String nickname,
  }) async {
    final url = Uri.parse('$baseUrl/group');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('로그인이 필요합니다.');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "groupName": groupName,
          "groupCode": password,
          "groupColor": groupColor,
          "numPeople": memberCount,
          "nickname": nickname,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true) {
          return data['result']['groupId'];
        } else {
          throw Exception(data['message']);
        }
      } else if (response.statusCode == 403) {
        throw Exception('권한이 없습니다(로그인 만료 가능성)');
      } else {
        throw Exception('서버 에러 : ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
