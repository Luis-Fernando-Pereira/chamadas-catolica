// lib/services/lesson_storage.dart
import 'dart:convert';
import 'package:appchamada/model/lesson.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonStorage {
  static const String _key = 'lessons_data';

  // Salva uma LISTA COMPLETA de aulas.
  static Future<void> saveLessons(List<Lesson> lessons) async {
    final prefs = await SharedPreferences.getInstance();
    // Converte a lista de objetos Lesson para uma lista de Mapas (JSON)
    final List<Map<String, dynamic>> lessonsJson = lessons
        .map((lesson) => lesson.toJson())
        .toList();
    // Codifica a lista de mapas em uma única string JSON
    final jsonString = jsonEncode(lessonsJson);
    await prefs.setString(_key, jsonString);
  }

  // Busca a lista de aulas salvas.
  static Future<List<Lesson>?> getLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    // Decodifica a string JSON para uma lista de mapas dinâmicos
    final List<dynamic> jsonData = json.decode(jsonString);
    // Converte cada mapa de volta para um objeto Lesson
    return jsonData.map((e) => Lesson.fromJson(e)).toList();
  }

  // Limpa os dados
  static Future<void> clearLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
