// lib/services/subject_storage.dart

import 'dart:convert';
import 'package:appchamada/model/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectStorage {
  static const String _key = 'subjects_data';

  // Salva uma LISTA COMPLETA de matérias.
  static Future<void> saveSubjects(List<Subject> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> subjectsJson = subjects
        .map((subject) => subject.toJson())
        .toList();
    final jsonString = jsonEncode(subjectsJson);
    await prefs.setString(_key, jsonString);
  }

  // Busca a lista de matérias salvas.
  static Future<List<Subject>?> getSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => Subject.fromJson(e)).toList();
  }

  // Limpa os dados de matérias.
  static Future<void> clearSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
