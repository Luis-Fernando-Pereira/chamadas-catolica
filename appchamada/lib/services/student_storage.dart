// lib/services/student_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/student.dart';

class StudentStorage {
  static const String _key = 'student_data';

  static Future<void> saveStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(student.toJson());
    await prefs.setString(_key, jsonString);
  }

  static Future<Student?> getStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    final jsonData = jsonDecode(jsonString);
    return Student.fromJson(jsonData);
  }

  static Future<void> clearStudent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
