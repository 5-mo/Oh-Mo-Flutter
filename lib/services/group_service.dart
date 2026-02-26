import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

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
    final Map<String, dynamic> body = {
      "groupName": groupName,
      "groupPassword": password,
      "groupColor": groupColor,
      "numPeople": memberCount,
      "nickname": nickname,
    };

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        return Map<String, dynamic>.from(data['result']);
      } else {
        throw Exception(data['message'] ?? '그룹 생성 실패');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchGroups() async {
    final url = Uri.parse('$baseUrl/group');

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && decodedData['isSuccess'] == true) {
        return List<Map<String, dynamic>>.from(decodedData['result']);
      }
      return [];
    } catch (e) {
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

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        ),
      );
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && decodedData['isSuccess'] == true) {
        final List<dynamic> resultList = decodedData['result'] ?? [];
        if (resultList.isNotEmpty) return resultList[0]['routineId'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int?> createGroupTodo({
    required int groupId,
    required String content,
    required String date,
    String? time,
  }) async {
    final url = Uri.parse('$baseUrl/group-schedule/todo');
    final body = {
      "groupId": groupId,
      "content": content,
      "date": date,
      "time": time ?? "00:00",
      "routineWeek": [],
    };
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ),
      );

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return (decoded['isSuccess'] == true)
          ? decoded['result']['todoId']
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> registerAssigneeTodo({
    required int todoId,
    required int memberGroupId,
  }) async {
    final url = Uri.parse('$baseUrl/group-schedule/assignee-todo');
    final body = {"todoId": todoId, "memberGroupId": memberGroupId};
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return decoded['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('담당자 지정 에러: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchAssigneeTodo(int todoId) async {
    final url = Uri.parse(
      '$baseUrl/group-schedule/assignee-todo?todoId=$todoId',
    );
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(url, headers: {'Authorization': 'Bearer $token'}),
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
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          url,
          headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
        ),
      );

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && decoded['isSuccess'] == true) {
        return decoded['result'];
      }
      return null;
    } catch (e) {
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
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
      );

      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && decodedData['isSuccess'] == true) {
        return decodedData['result'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchGroupMembers(int groupId) async {
    final url = Uri.parse(
      '$baseUrl/group/member',
    ).replace(queryParameters: {'groupId': groupId.toString()});
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
      );

      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && decodedData['isSuccess'] == true) {
        return Map<String, dynamic>.from(decodedData['result']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> registerAssigneeRoutine({
    required int routineId,
    required List<int> memberGroupIdList,
  }) async {
    final url = Uri.parse('$baseUrl/group-schedule/assignee-routine');
    final Map<String, dynamic> body = {
      "routineId": routineId,
      "memberGroupId":
          memberGroupIdList.isNotEmpty ? memberGroupIdList[0] : null,
    };

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        ),
      );

      final decodedData = json.decode(utf8.decode(response.bodyBytes));

      return response.statusCode == 200 && decodedData['isSuccess'] == true;
    } catch (e) {
      print("담당자 등록 에러: $e");
      return false;
    }
  }

  Future<bool> updateGroupNickname({
    required int groupId,
    required String nickname,
  }) async {
    final url = Uri.parse('$baseUrl/group/nickname');

    final body = {"groupId": groupId, "nickname": nickname};
    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      return response.statusCode == 200 && data['isSuccess'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> enterGroup({
    required String groupCode,
    required String groupPassword,
    required String nickname,
  }) async {
    final url = Uri.parse('$baseUrl/group/enter');
    final Map<String, dynamic> body = {
      "groupCode": groupCode,
      "groupPassword": groupPassword,
      "nickname": nickname,
    };

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        return Map<String, dynamic>.from(data['result']);
      } else {
        throw Exception(data['message'] ?? '그룹 입장에 실패했습니다.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getMyEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  Future<bool> deleteGroup({
    required int groupId,
    required String groupPassword,
  }) async {
    final url = Uri.parse('$baseUrl/group');
    final Map<String, dynamic> body = {
      "groupId": groupId,
      "groupPassword": groupPassword,
    };

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.delete(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && data['isSuccess'] == true) return true;
      throw Exception(data['message'] ?? '그룹 삭제 실패');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateAssigneeStatus(int assigneeId) async {
    final url = Uri.parse(
      '$baseUrl/group-schedule/assignee/status?assigneeId=$assigneeId',
    );

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
          body: '',
        ),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return true;
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        return decodedData['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('담당자 상태 변경 에러 : $e');
      return false;
    }
  }

  Future<bool> createNotice({
    required int groupId,
    required String notice,
    required String date,
  }) async {
    final url = Uri.parse('$baseUrl/notice');
    final body = {"notice": notice, "date": date, "groupId": groupId};

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ),
      );

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && decoded['isSuccess'] == true) {
        return true;
      } else {
        print("등록 실패: ${decoded['message']}");
        return false;
      }
    } catch (e) {
      print('통신 에러: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchNotices({
    required int groupId,
    required String date,
  }) async {
    final url = Uri.parse(
      '$baseUrl/notice',
    ).replace(queryParameters: {'groupId': groupId.toString(), 'date': date});

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
      return (response.statusCode == 200 && decodedData['isSuccess'] == true)
          ? decodedData['result'] ?? []
          : [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateNotice({
    required int noticeId,
    required String notice,
    required String date,
  }) async {
    final url = Uri.parse(
      '$baseUrl/notice',
    ).replace(queryParameters: {'noticeId': noticeId.toString()});
    final body = {"notice": notice, "date": date};

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ),
      );

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return response.statusCode == 200 && decoded['isSuccess'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotice({required int noticeId}) async {
    final url = Uri.parse(
      '$baseUrl/notice',
    ).replace(queryParameters: {'noticeId': noticeId.toString()});

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.delete(
          url,
          headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
        ),
      );

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      print("공지 삭제 서버 응답 : $decoded");

      return response.statusCode == 200 && decoded['isSuccess'] == true;
    } catch (e) {
      print('공지 삭제 통신 에러 : $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchNoticesByMonth({
    required int groupId,
    required String yearMonth,
  }) async {
    final url = Uri.parse('$baseUrl/notice/by-month').replace(
      queryParameters: {'groupId': groupId.toString(), 'yearMonth': yearMonth},
    );

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
      return (response.statusCode == 200 && decodedData['isSuccess'] == true)
          ? decodedData['result'] ?? []
          : [];
    } catch (e) {
      return [];
    }
  }
}
