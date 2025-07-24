import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static String _keyAnswer(String date) => 'saved_answer_$date';
  static String _keyDiary(String date) => 'saved_diary_$date';

  // 저장
  static Future<void> saveAnswer(String date, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAnswer(date), answer);
  }

  static Future<void> saveDiary(String date, String diary) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDiary(date), diary);
  }

  // 불러오기
  static Future<String> loadAnswer(String date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAnswer(date)) ?? '';
  }

  static Future<String> loadDiary(String date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDiary(date)) ?? '';
  }
}
