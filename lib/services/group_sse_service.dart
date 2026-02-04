import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupSseService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://52.79.75.26:8080/api';

  Stream<String> subscribeGroup(int groupId) async* {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    try {
      final response = await _dio.get(
        '$baseUrl/group/$groupId/subscribe',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
          responseType: ResponseType.stream,
        ),
      );

      await for (final List<int> chunk in response.data.stream) {
        final decoded = utf8.decode(chunk);

        final lines = decoded.split('\n');
        for (var line in lines) {
          if (line.startsWith('data:')) {
            final data = line.replaceFirst('data:', '').trim();
            if (data.isNotEmpty) {
              yield data;
            }
          }
        }
      }
    } catch (e) {
      if (e is DioException) {
        print("===== [SSE] 403 에러 상세 분석 =====");
        print("상태 코드: ${e.response?.statusCode}");

        if (e.response?.data is ResponseBody) {
          try {
            final responseBody = e.response?.data as ResponseBody;
            final errorChunks = await responseBody.stream.toList();
            final errorBody = utf8.decode(
              errorChunks.expand((i) => i).toList(),
            );
            print("서버 에러 메시지: $errorBody");
          } catch (e2) {
            print("에러 바디를 읽는 중 오류 발생: $e2");
          }
        } else {
          print("서버 응답: ${e.response?.data}");
        }
        print("================================");
      } else {
        print("[SSE 연결 에러] : $e");
      }
      await Future.delayed(const Duration(seconds: 5));
      yield* subscribeGroup(groupId);
    }
  }
}
