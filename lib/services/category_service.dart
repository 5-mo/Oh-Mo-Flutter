import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class CategoryService {
  static const String baseUrl = 'http://3.36.161.109:8080';

  Future<int?> createCategory({
    required String categoryName,
    required String color,
    required String scheduleType,
  }) async {
    final url = Uri.parse('$baseUrl/api/category');

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "categoryName": categoryName,
            "color": color,
            "scheduleType": scheduleType,
          }),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true) {
          return data['result']['id'];
        }
      }
      return null;
    } catch (e) {
      print('카테고리 생성 실패 : $e');
      return null;
    }
  }

  Future<List<dynamic>> getCategories(String scheduleType) async {
    final url = Uri.parse('$baseUrl/api/category?schedule-type=$scheduleType');

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true) {
          final list = data['result'] as List;
          return list;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateCategory({
    required int categoryId,
    required String categoryName,
    required String color,
  }) async {
    final url = Uri.parse('$baseUrl/api/category/$categoryId');

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.patch(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "categoryName": categoryName,
            "color": color.toUpperCase(),
          }),
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonData['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('카테고리 수정 에러 : $e');
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    final url = Uri.parse('$baseUrl/api/category/$categoryId');

    try {
      final response = await AuthService.authenticatedRequest(
        (token) => http.delete(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonData['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('카테고리 삭제 에러 : $e');
      return false;
    }
  }
}
