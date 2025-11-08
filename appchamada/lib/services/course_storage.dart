// lib/services/course_storage.dart
import 'dart:convert';
import 'package:appchamada/model/course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseStorage {
  static const String _key = 'courses_data';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'courses';

  // ==================== FIREBASE ====================

  /// Salvar curso no Firebase
  static Future<void> saveCourseToFirebase(Course course) async {
    try {
      await _firestore.collection(_collection).doc(course.id.toString()).set({
        'id': course.id,
        'name': course.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Curso salvo no Firebase: ${course.name}');
    } catch (e) {
      print('❌ Erro ao salvar curso no Firebase: $e');
    }
  }

  /// Buscar todos os cursos do Firebase
  static Future<List<Course>> getCoursesFromFirebase() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      final courses = snapshot.docs.map((doc) {
        final data = doc.data();
        return Course(id: data['id'] as int, name: data['name'] as String?);
      }).toList();

      print('✅ ${courses.length} cursos carregados do Firebase');
      return courses;
    } catch (e) {
      print('❌ Erro ao buscar cursos do Firebase: $e');
      return [];
    }
  }

  /// Atualizar curso no Firebase
  static Future<void> updateCourseInFirebase(Course course) async {
    try {
      await _firestore.collection(_collection).doc(course.id.toString()).update(
        {'name': course.name, 'updatedAt': FieldValue.serverTimestamp()},
      );
      print('✅ Curso atualizado no Firebase: ${course.name}');
    } catch (e) {
      print('❌ Erro ao atualizar curso no Firebase: $e');
    }
  }

  /// Deletar curso do Firebase
  static Future<void> deleteCourseFromFirebase(int id) async {
    try {
      await _firestore.collection(_collection).doc(id.toString()).delete();
      print('✅ Curso deletado do Firebase: ID $id');
    } catch (e) {
      print('❌ Erro ao deletar curso do Firebase: $e');
    }
  }

  // ==================== SHARED PREFERENCES (CACHE) ====================

  /// Salvar curso no SharedPreferences (cache local)
  static Future<void> saveCourse(Course course) async {
    // Salvar no Firebase
    await saveCourseToFirebase(course);

    // Salvar no cache local
    final prefs = await SharedPreferences.getInstance();
    final List<Course> courses = await getCourses();

    // Verificar se já existe
    final existingIndex = courses.indexWhere((c) => c.id == course.id);
    if (existingIndex >= 0) {
      courses[existingIndex] = course;
    } else {
      courses.add(course);
    }

    final jsonString = jsonEncode(courses.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  /// Buscar cursos (Firebase primeiro, depois cache)
  static Future<List<Course>> getCourses() async {
    try {
      // Tentar buscar do Firebase primeiro
      final coursesFromFirebase = await getCoursesFromFirebase();

      if (coursesFromFirebase.isNotEmpty) {
        // Atualizar cache local
        final prefs = await SharedPreferences.getInstance();
        final jsonString = jsonEncode(
          coursesFromFirebase.map((e) => e.toJson()).toList(),
        );
        await prefs.setString(_key, jsonString);

        return coursesFromFirebase;
      }
    } catch (e) {
      print('⚠️ Erro ao buscar do Firebase, usando cache: $e');
    }

    // Fallback: buscar do cache local
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => Course.fromJson(e)).toList();
  }

  /// Atualizar curso
  static Future<void> updateCourse(Course updated) async {
    // Atualizar no Firebase
    await updateCourseInFirebase(updated);

    // Atualizar no cache local
    final prefs = await SharedPreferences.getInstance();
    final List<Course> courses = await getCourses();

    final idx = courses.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      courses[idx] = updated;
      final jsonString = jsonEncode(courses.map((e) => e.toJson()).toList());
      await prefs.setString(_key, jsonString);
    }
  }

  /// Deletar curso
  static Future<void> deleteCourse(int id) async {
    // Deletar do Firebase
    await deleteCourseFromFirebase(id);

    // Deletar do cache local
    final prefs = await SharedPreferences.getInstance();
    final List<Course> courses = await getCourses();

    courses.removeWhere((c) => c.id == id);
    final jsonString = jsonEncode(courses.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  /// Limpar cache local
  static Future<void> clearCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ==================== SEED DATA ====================

  /// Criar cursos iniciais (apenas se não existir nenhum)
  static Future<void> seedCoursesIfEmpty() async {
    final courses = await getCoursesFromFirebase();

    if (courses.isEmpty) {
      print('📦 Criando cursos iniciais...');

      final initialCourses = [
        Course(id: 1, name: 'Engenharia de Software'),
      ];

      for (final course in initialCourses) {
        await saveCourseToFirebase(course);
      }

      print('✅ Cursos iniciais criados!');
    }
  }
}
