import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryItem {
  final int id;
  final String categoryName;
  late final String content;
  final String colorType;
  final String scheduleType;


  CategoryItem({
    required this.id,
    required this.categoryName,
    required this.content,
    required this.colorType,
    required this.scheduleType,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'],
      content: json['categoryName'],
      categoryName: json['categoryName'],
      colorType: json['color'],
      scheduleType: json['scheduleType'],
    );
  }
}

class CategoryService {
  // POST: 카테고리 등록
  static Future<CategoryItem> registerCategory({
    required String name,
    required String color,
    required String scheduleType,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://43.201.188.84:8080/api/category');

    final body = jsonEncode({
      'categoryName': name,
      'color': color,
      'scheduleType': scheduleType,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final decodeBody = utf8.decode(response.bodyBytes);
    print('등록 응답 body: $decodeBody');

    if (response.statusCode != 200) {
      throw Exception('서버 오류: ${response.statusCode}');
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(decodeBody);
    } catch (e) {
      throw Exception('응답 JSON 파싱 실패: $e');
    }

    if (data['isSuccess'] == true) {
      final result = data['result'];
      return CategoryItem.fromJson(result);
    } else {
      final message = data['message'] ?? '카테고리 등록 실패';
      throw Exception('카테고리 등록 실패: $message');
    }
  }

  // GET: 카테고리 조회
  static Future<List<CategoryItem>> fetchCategories({
    required String scheduleType,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://43.201.188.84:8080/api/category?schedule-type=$scheduleType');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final decodeBody = utf8.decode(response.bodyBytes);
    print('조회 응답 body: $decodeBody');

    if (response.statusCode != 200) {
      throw Exception('카테고리 조회 실패 : ${response.statusCode}');
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(decodeBody);
    } catch (e) {
      throw Exception('응답 JSON 파싱 실패: $e');
    }

    if (data['isSuccess'] == true) {
      final List<dynamic> results = data['result'];
      return results.map((e) => CategoryItem.fromJson(e)).toList();
    } else {
      final message = data['message'] ?? '카테고리 조회 실패';
      throw Exception('카테고리 조회 실패: $message');
    }
  }
}
