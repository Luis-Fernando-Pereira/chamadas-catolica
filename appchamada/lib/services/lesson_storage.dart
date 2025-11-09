// lib/services/lesson_storage.dart
import 'dart:convert';
import 'package:appchamada/model/lesson.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LessonStorage {
  static const String _key = 'lessons_data';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'lessons';

  static Future<void> saveLesson(Lesson lesson) async {
    try {
      final data = lesson.toJson();
      await _firestore.collection(_collection).doc(lesson.id.toString()).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao salvar aula: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final lessons = await getLessons() ?? [];
    final index = lessons.indexWhere((l) => l.id == lesson.id);
    if (index >= 0) {
      lessons[index] = lesson;
    } else {
      lessons.add(lesson);
    }
    await prefs.setString(
      _key,
      jsonEncode(lessons.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<Lesson>?> getLessons() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      if (snapshot.docs.isNotEmpty) {
        final lessons = snapshot.docs
            .map((doc) => Lesson.fromJson(doc.data()))
            .toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _key,
          jsonEncode(lessons.map((e) => e.toJson()).toList()),
        );
        return lessons;
      }
    } catch (e) {
      print('⚠️ Erro Firebase, usando cache: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => Lesson.fromJson(e)).toList();
  }

  static Future<void> saveLessons(List<Lesson> lessons) async {
    for (final lesson in lessons) {
      await saveLesson(lesson);
    }
  }

  static Future<void> updateLesson(Lesson lesson) async {
    try {
      final data = lesson.toJson();
      await _firestore.collection(_collection).doc(lesson.id.toString()).update(
        {...data, 'updatedAt': FieldValue.serverTimestamp()},
      );
    } catch (e) {
      print('❌ Erro ao atualizar: $e');
    }
    await saveLesson(lesson);
  }

  static Future<void> deleteLesson(int id) async {
    try {
      await _firestore.collection(_collection).doc(id.toString()).delete();
    } catch (e) {
      print('❌ Erro ao deletar: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final lessons = await getLessons() ?? [];
    lessons.removeWhere((l) => l.id == id);
    await prefs.setString(
      _key,
      jsonEncode(lessons.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clearLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
