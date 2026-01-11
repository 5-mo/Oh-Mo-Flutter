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
          "groupPassword": password,
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

  Future<List<Map<String, dynamic>>> fetchGroups() async {
    final url = Uri.parse('$baseUrl/group');

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');

      if (token == null) return [];

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
      print("[그룹 목록 조회 응답] : $decodedData");

      if (response.statusCode == 200 && decodedData['isSuccess'] == true) {
        return List<Map<String, dynamic>>.from(decodedData['result']);
      } else {
        return [];
      }
    } catch (e) {
      print("[fetchGroups 에러] : $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getGroupDetail(int groupId) async {
    final List<dynamic> groups = await fetchGroups();

    try {
      return groups.firstWhere((g) => g['groupId'] == groupId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createGroupRoutine({
    required int groupId,
    required String content,
    required List<String> routineWeek,
    required String date,
    String? time,
    String? alarmTime,
  }) async {
    final url = Uri.parse('$baseUrl/group-schedule/routine');

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');
      if (token == null) return false;

      final Map<String, dynamic> body = {
        "groupId": groupId,
        "content": content,
        "date": date,
        "routineWeek": routineWeek,
        "time": (time == null || time.isEmpty) ? "00:00" : time.substring(0, 5),
      };

      if (alarmTime != null && alarmTime.trim().isNotEmpty) {
        body["alarmTime"] = alarmTime.substring(0, 5);
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return true;
        }

        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        return decodedData['isSuccess'] == true;
      } else {
        print("[서버 에러]: 상태코드 ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("[createGroupRoutine 에러]: $e");
      return false;
    }
  }

  Future<bool> createGroupTodo({
    required int groupId,
    required String content,
    required String date,
    String? time,
    String? alarmTime,
  }) async {
    final url = Uri.parse('$baseUrl/group-schedule/todo');

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');

      final Map<String, dynamic> body = {
        "groupId": groupId,
        "content": content,
        "date": date,
        "time": (time == null || time.isEmpty) ? "00:00" : time,
        "routineWeek": [],
      };

      if (alarmTime != null && alarmTime.trim().isNotEmpty) {
        body['alarmTime'] = alarmTime;
      }
      print("[투두 전송 최종 JSON]:${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return true;
        final decodedDate = json.decode(utf8.decode(response.bodyBytes));
        return decodedDate['isSuccess'] == true;
      } else {
        print("[투두 서버 에러] : ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("[createGroupTodo 에러]:$e");
      return false;
    }
  }
}
