// lib/services/student_storage.dart
import 'dart:convert';
import 'package:appchamada/model/lesson.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonStorage {
  static const String _key = 'lessons_data';

  static Future<void> saveLesson(Lesson lesson) async {
    final prefs = await SharedPreferences.getInstance();

    final List<Lesson>? lessons = await LessonStorage.getLessons();

    lessons?.add(lesson);

    final jsonString = jsonEncode(jsonEncode(lessons));
    await prefs.setString(_key, jsonString);
  }

  static Future<List<Lesson>?> getLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => Lesson.fromJson(e)).toList();
  }

  static Future<void> clearStudent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}