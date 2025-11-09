// lib/services/class_storage.dart
import 'dart:convert';
import 'package:appchamada/model/assigned_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassStorage {
  static const String _key = 'classes_data';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'classes';

  // ==================== FIREBASE ====================

  /// Salvar turma no Firebase
  static Future<void> saveClassToFirebase(AssignedClass assignedClass) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(assignedClass.id.toString())
          .set({
            'id': assignedClass.id,
            'name': assignedClass.name,
            'createdAt': FieldValue.serverTimestamp(),
          });
      print('✅ Turma salva no Firebase: ${assignedClass.name}');
    } catch (e) {
      print('❌ Erro ao salvar turma no Firebase: $e');
    }
  }

  /// Buscar todas as turmas do Firebase
  static Future<List<AssignedClass>> getClassesFromFirebase() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      final classes = snapshot.docs.map((doc) {
        final data = doc.data();
        return AssignedClass(
          id: data['id'] as int,
          name: data['name'] as String?,
        );
      }).toList();

      print('✅ ${classes.length} turmas carregadas do Firebase');
      return classes;
    } catch (e) {
      print('❌ Erro ao buscar turmas do Firebase: $e');
      return [];
    }
  }

  /// Atualizar turma no Firebase
  static Future<void> updateClassInFirebase(AssignedClass assignedClass) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(assignedClass.id.toString())
          .update({
            'name': assignedClass.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      print('✅ Turma atualizada no Firebase: ${assignedClass.name}');
    } catch (e) {
      print('❌ Erro ao atualizar turma no Firebase: $e');
    }
  }

  /// Deletar turma do Firebase
  static Future<void> deleteClassFromFirebase(int id) async {
    try {
      await _firestore.collection(_collection).doc(id.toString()).delete();
      print('✅ Turma deletada do Firebase: ID $id');
    } catch (e) {
      print('❌ Erro ao deletar turma do Firebase: $e');
    }
  }

  // ==================== SHARED PREFERENCES (CACHE) ====================

  /// Salvar turma
  static Future<void> saveClass(AssignedClass assignedClass) async {
    // Salvar no Firebase
    await saveClassToFirebase(assignedClass);

    // Salvar no cache local
    final prefs = await SharedPreferences.getInstance();
    final List<AssignedClass> classes = await getClasses();

    // Verificar se já existe
    final existingIndex = classes.indexWhere((c) => c.id == assignedClass.id);
    if (existingIndex >= 0) {
      classes[existingIndex] = assignedClass;
    } else {
      classes.add(assignedClass);
    }

    final jsonString = jsonEncode(classes.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  /// Buscar turmas (Firebase primeiro, depois cache)
  static Future<List<AssignedClass>> getClasses() async {
    try {
      // Tentar buscar do Firebase primeiro
      final classesFromFirebase = await getClassesFromFirebase();

      if (classesFromFirebase.isNotEmpty) {
        // Atualizar cache local
        final prefs = await SharedPreferences.getInstance();
        final jsonString = jsonEncode(
          classesFromFirebase.map((e) => e.toJson()).toList(),
        );
        await prefs.setString(_key, jsonString);

        return classesFromFirebase;
      }
    } catch (e) {
      print('⚠️ Erro ao buscar do Firebase, usando cache: $e');
    }

    // Fallback: buscar do cache local
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => AssignedClass.fromJson(e)).toList();
  }

  /// Atualizar turma
  static Future<void> updateClass(AssignedClass updated) async {
    // Atualizar no Firebase
    await updateClassInFirebase(updated);

    // Atualizar no cache local
    final prefs = await SharedPreferences.getInstance();
    final List<AssignedClass> classes = await getClasses();

    final idx = classes.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      classes[idx] = updated;
      final jsonString = jsonEncode(classes.map((e) => e.toJson()).toList());
      await prefs.setString(_key, jsonString);
    }
  }

  /// Deletar turma
  static Future<void> deleteClass(int id) async {
    // Deletar do Firebase
    await deleteClassFromFirebase(id);

    // Deletar do cache local
    final prefs = await SharedPreferences.getInstance();
    final List<AssignedClass> classes = await getClasses();

    classes.removeWhere((c) => c.id == id);
    final jsonString = jsonEncode(classes.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  /// Limpar cache local
  static Future<void> clearClasses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ==================== SEED DATA ====================

  /// Criar turmas iniciais (apenas se não existir nenhuma)
  static Future<void> seedClassesIfEmpty() async {
    final classes = await getClassesFromFirebase();

    if (classes.isEmpty) {
      print('📦 Criando turmas iniciais...');

      final initialClasses = [
        AssignedClass(id: 101, name: 'A'),
        AssignedClass(id: 102, name: 'B'),
      ];

      for (final assignedClass in initialClasses) {
        await saveClassToFirebase(assignedClass);
      }

      print('✅ Turmas iniciais criadas!');
    }
  }
}
