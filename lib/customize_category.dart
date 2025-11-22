import 'package:shared_preferences/shared_preferences.dart';

class RoutineVisibilityHelper {
  static const String _key = 'isRoutineVisible';

  static Future<bool> getVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<void> setVisibility(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isVisible);
  }
}

class TodoVisibilityHelper {
  static const String _key = 'isTodoVisible';

  static Future<bool> getVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<void> setVisibility(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isVisible);
  }
}

class QuestionVisibilityHelper {
  static const String _key = 'isQuestionVisible';

  static Future<bool> getVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<void> setVisibility(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isVisible);
  }
}

class GroupVisibilityHelper {
  static const String _key = 'isGroupVisible';

  static Future<bool> getVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<void> setVisibility(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isVisible);
  }
}

class DiaryVisibilityHelper {
  static const String _key = 'isDiaryVisible';

  static Future<bool> getVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<void> setVisibility(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isVisible);
  }
}
