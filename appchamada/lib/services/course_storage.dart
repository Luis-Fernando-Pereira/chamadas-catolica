// lib/services/course_storage.dart
import 'dart:convert';
import 'package:appchamada/model/course.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseStorage {
  static const String _key = 'courses_data';

  static Future<void> saveCourse(Course course) async {
    final prefs = await SharedPreferences.getInstance();

    final List<Course> courses = (await getCourses()) ?? [];

    courses.add(course);

    final jsonString = jsonEncode(courses.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<List<Course>?> getCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => Course.fromJson(e)).toList();
  }

  static Future<void> updateCourse(Course updated) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Course> courses = (await getCourses()) ?? [];

    final idx = courses.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      courses[idx] = updated;
      final jsonString = jsonEncode(courses.map((e) => e.toJson()).toList());
      await prefs.setString(_key, jsonString);
    }
  }

  static Future<void> deleteCourse(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Course> courses = (await getCourses()) ?? [];

    courses.removeWhere((c) => c.id == id);
    final jsonString = jsonEncode(courses.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<void> clearCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
