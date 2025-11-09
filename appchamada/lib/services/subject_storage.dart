// lib/services/subject_storage.dart
import 'dart:convert';
import 'package:appchamada/model/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectStorage {
  static const String _key = 'subjects_data';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'subjects';

  static Future<void> saveSubject(Subject subject) async {
    try {
      await _firestore.collection(_collection).doc(subject.id.toString()).set({
        'id': subject.id,
        'name': subject.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao salvar matéria: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final subjects = await getSubjects();
    final index = subjects.indexWhere((s) => s.id == subject.id);
    if (index >= 0) {
      subjects[index] = subject;
    } else {
      subjects.add(subject);
    }
    await prefs.setString(
      _key,
      jsonEncode(subjects.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<Subject>> getSubjects() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      if (snapshot.docs.isNotEmpty) {
        final subjects = snapshot.docs.map((doc) {
          final data = doc.data();
          return Subject(id: data['id'] as int, name: data['name'] as String?);
        }).toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _key,
          jsonEncode(subjects.map((e) => e.toJson()).toList()),
        );
        return subjects;
      }
    } catch (e) {
      print('⚠️ Erro Firebase, usando cache: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => Subject.fromJson(e)).toList();
  }

  static Future<void> saveSubjects(List<Subject> subjects) async {
    for (final subject in subjects) {
      await saveSubject(subject);
    }
  }

  static Future<void> updateSubject(Subject subject) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(subject.id.toString())
          .update({
            'name': subject.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('❌ Erro ao atualizar: $e');
    }
    await saveSubject(subject);
  }

  static Future<void> deleteSubject(int id) async {
    try {
      await _firestore.collection(_collection).doc(id.toString()).delete();
    } catch (e) {
      print('❌ Erro ao deletar: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final subjects = await getSubjects();
    subjects.removeWhere((s) => s.id == id);
    await prefs.setString(
      _key,
      jsonEncode(subjects.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clearSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> seedSubjectsIfEmpty() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      if (snapshot.docs.isEmpty) {
        final subjects = [
          Subject(id: 1, name: 'DESENVOLVIMENTO DE DISPOSITIVOS MÓVEIS'),
          Subject(id: 2, name: 'MATEMÁTICA COMPUTACIONAL'),
          Subject(id: 3, name: 'GESTÃO DE PROJETOS'),
          Subject(
            id: 4,
            name:
                'PROJETO DE APRENDIZAGEM COLABORATIVA EXTENSIONISTA IV - PAC ESOFT',
          ),
          Subject(
            id: 5,
            name: 'GERENCIAMENTO, CONFIGURAÇÃO E PROCESSOS DE SOFTWARE',
          ),
        ];
        for (final s in subjects) {
          await _firestore.collection(_collection).doc(s.id.toString()).set({
            'id': s.id,
            'name': s.name,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        print('✅ Matérias iniciais criadas');
      }
    } catch (e) {
      print('⚠️ Erro ao criar matérias iniciais: $e');
    }
  }
}
