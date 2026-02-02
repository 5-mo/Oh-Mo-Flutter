import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupService {
  static const String baseUrl = 'http://52.79.75.26:8080/api';

  Future<Map<String, dynamic>> createGroup({
    required String groupName,
    required String password,
    required String groupColor,
    required int memberCount,
    required String nickname,
  }) async {
    final url = Uri.parse('$baseUrl/group');
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) throw Exception('로그인이 필요합니다.');

    final Map<String, dynamic> body = {
      "groupName": groupName,
      "groupPassword": password,
      "groupColor": groupColor,
      "numPeople": memberCount,
      "nickname": nickname,
    };

    try {
      print("[그룹 생성 요청] POST $url");
      print("[그룹 생성 바디] ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print("[그룹 생성 응답] 상태코드: ${response.statusCode}, 결과: $data");

      if (response.statusCode == 200) {
        if (data['isSuccess'] == true) {
          return Map<String, dynamic>.from(data['result']);
        } else {
          throw Exception(data['message']);
        }
      } else if (response.statusCode == 403) {
        throw Exception('권한이 없습니다(로그인 만료 가능성)');
      } else {
        throw Exception('서버 에러 : ${response.statusCode}');
      }
    } catch (e) {
      print("[createGroup 에러] $e");
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

  Future<int?> createGroupRoutine({
    required int? groupId,
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
      if (token == null) return null;

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
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && decodedData['isSuccess'] == true) {
        final List<dynamic> resultList = decodedData['result'] ?? [];
        if (resultList.isNotEmpty && resultList[0]['routineId'] != null) {
          return resultList[0]['routineId'];
        }
      }
      return null;
    } catch (e) {
      print("[createGroupRoutine 에러]: $e");
      return null;
    }
  }

  Future<int?> createGroupTodo({
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
      if (token == null) return null;

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

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && decoded['isSuccess'] == true) {
        final result = decoded['result'];
        print("서버 응답 result 내용: $result");
        if (result != null && result['todoId'] != null) {
          return result['todoId'];
        } else {
          print("[createGroupTodo] 성공했으나 todoId가 응답에 없음. 실제 데이터: $result");
          return null;
        }
      }
      return null;
    } catch (e) {
      print("[createGroupTodo 에러]:$e");
      return null;
    }
  }

  Future<bool> registerAssigneeTodo({
    required int todoId,
    required List<int> memberGroupIdList,
  }) async {
    final url = Uri.parse('$baseUrl/group-schedule/assignee-todo');
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');
      if (token == null) return false;

      final body = {"todoId": todoId, "memberGroupIdList": memberGroupIdList};

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return response.statusCode == 200 && decoded['isSuccess'] == true;
    } catch (e) {
      print("[registerAssigneeTodo 에러 : $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchAssigneeTodo(int todoId) async {
    final url = Uri.parse(
      '$baseUrl/group-schedule/assignee-todo?todoId=$todoId',
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');
      if (token == null) return [];

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return (decoded['isSuccess'] == true) ? decoded['result'] : [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchAssigneeRoutine(int routineId) async {
    final url = Uri.parse(
      '$baseUrl/group-schedule/assignee-routine?routineId=$routineId',
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');
      if (token == null) return null;

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
      );

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && decoded['isSuccess'] == true) {
        return decoded['result'];
      }
      return null;
    } catch (e) {
      print("[fetchAssigneeRoutine 에러] : $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchGroupSchedules({
    required int groupId,
    required String date,
  }) async {
    final url = Uri.parse(
      '$baseUrl/group-schedule/by-date',
    ).replace(queryParameters: {'groupId': groupId.toString(), 'date': date});

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      print("[API 요청] GET $url");
      print("[응답 상태] ${response.statusCode}");

      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
      print("[응답 바디] $decodedData");

      if (response.statusCode == 200 && decodedData['isSuccess'] == true) {
        return decodedData['result'];
      } else {
        print("[fetchGroupSchedules 실패]: ${decodedData['message']}");
        return null;
      }
    } catch (e) {
      print("[fetchGroupSchedules 에러]: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> enterGroup({
    required String groupCode,
    required String groupPassword,
    required String nickname,
  }) async {
    final url = Uri.parse('$baseUrl/group/enter');
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) throw Exception('로그인이 필요합니다.');
    final Map<String, dynamic> body = {
      "groupCode": groupCode,
      "groupPassword": groupPassword,
      "nickname": nickname,
    };

    try {
      print("[그룹 입장 요청] POST $url");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print("[그룹 입장 응답] $data");

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        return Map<String, dynamic>.from(data['result']);
      } else {
        throw Exception(data['message'] ?? '그룹 입장에 실패했습니다.');
      }
    } catch (e) {
      print("[entergroup 에러]$e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchGroupMembers(int groupId) async {
    final url = Uri.parse(
      '$baseUrl/group/member',
    ).replace(queryParameters: {'groupId': groupId.toString()});
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');

      if (token == null) return null;

      print("[그룹 멤버 조회 요청] GET $url");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
      print("[그룹 멤버 조회 응답] 상태코드 : ${response.statusCode}, 결과 : $decodedData");

      if (response.statusCode == 200 && decodedData['isSuccess'] == true) {
        return Map<String, dynamic>.from(decodedData['result']);
      } else {
        print("[fetchGroupMembers 실패]:${decodedData['message']}");
        return null;
      }
    } catch (e) {
      print("[fetchGroupMembers 에러]: $e");
      return null;
    }
  }

  Future<String?> getMyEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  Future<bool> registerAssigneeRoutine({
    required int routineId,
    required List<int> memberGroupIdList,
  }) async {
    final url = Uri.parse('$baseUrl/group-schedule/assignee-routine');

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');
      if (token == null) return false;

      final Map<String, dynamic> body = {
        "routineId": routineId,
        "memberGroupIdList": memberGroupIdList,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      print("[담당자 등록 응답] : $decodedData");

      return response.statusCode == 200 && decodedData['isSuccess'] == true;
    } catch (e) {
      print("[registerAssigneeRoutine 에러]: $e");
      return false;
    }
  }

  Future<bool> updateGroupNickname({
    required int groupId,
    required String nickname,
  }) async {
    final url = Uri.parse('$baseUrl/group/nickname');
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) throw Exception('로그인이 필요합니다.');

    final body = {"groupId": groupId, "nickname": nickname};

    try {
      print("[닉네임 업데이트 요청] PATCH $url");
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print("[닉네임 업데이트 응답] $data");

      return response.statusCode == 200 && data['isSuccess'] == true;
    } catch (e) {
      print("[updateGroupNickname 에러]$e");
      return false;
    }
  }
}
