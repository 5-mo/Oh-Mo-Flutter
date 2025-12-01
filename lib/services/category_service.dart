import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryService {
  static const String baseUrl = 'http://54.116.11.20:8080';

  Future<int?> createCategory({
    required String categoryName,
    required String color,
    required String scheduleType,
  }) async {
    final url = Uri.parse('$baseUrl/api/category');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) return null;

    try {

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "categoryName": categoryName,
          "color": color,
          "scheduleType": scheduleType,
        }),
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

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) return [];

    try {

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
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
}