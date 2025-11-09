// lib/services/class_room_storage.dart
import 'dart:convert';
import 'package:appchamada/model/class_room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassRoomStorage {
  static const String _key = 'class_rooms_data';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'class_rooms';

  static Future<void> saveClassRoom(ClassRoom classRoom) async {
    try {
      final data = classRoom.toJson();
      await _firestore.collection(_collection).doc(classRoom.id.toString()).set(
        {...data, 'createdAt': FieldValue.serverTimestamp()},
      );
    } catch (e) {
      print('❌ Erro ao salvar sala: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final classRooms = await getClassRooms();
    final index = classRooms.indexWhere((c) => c.id == classRoom.id);
    if (index >= 0) {
      classRooms[index] = classRoom;
    } else {
      classRooms.add(classRoom);
    }
    await prefs.setString(
      _key,
      jsonEncode(classRooms.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<ClassRoom>> getClassRooms() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      if (snapshot.docs.isNotEmpty) {
        final classRooms = snapshot.docs
            .map((doc) => ClassRoom.fromJson(doc.data()))
            .toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _key,
          jsonEncode(classRooms.map((e) => e.toJson()).toList()),
        );
        return classRooms;
      }
    } catch (e) {
      print('⚠️ Erro Firebase, usando cache: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => ClassRoom.fromJson(e)).toList();
  }

  static Future<void> updateClassRoom(ClassRoom classRoom) async {
    try {
      final data = classRoom.toJson();
      await _firestore
          .collection(_collection)
          .doc(classRoom.id.toString())
          .update({...data, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('❌ Erro ao atualizar: $e');
    }
    await saveClassRoom(classRoom);
  }

  static Future<void> deleteClassRoom(int id) async {
    try {
      await _firestore.collection(_collection).doc(id.toString()).delete();
    } catch (e) {
      print('❌ Erro ao deletar: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final classRooms = await getClassRooms();
    classRooms.removeWhere((c) => c.id == id);
    await prefs.setString(
      _key,
      jsonEncode(classRooms.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clearClassRooms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> seedClassRoomsIfEmpty() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      if (snapshot.docs.isEmpty) {
        final classRooms = [
          ClassRoom(id: 201, name: 'Sala 301 - Bloco C'),
          ClassRoom(id: 202, name: 'Laboratório A'),
          ClassRoom(id: 203, name: 'Auditório Principal'),
        ];
        for (final c in classRooms) {
          await _firestore.collection(_collection).doc(c.id.toString()).set({
            'id': c.id,
            'name': c.name,
            'position': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        print('✅ Salas iniciais criadas');
      }
    } catch (e) {
      print('⚠️ Erro ao criar salas iniciais: $e');
    }
  }
}
