// lib/services/user_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';

class UserStorage {
  static const String _key = 'users_data';

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    // Carregar usuários existentes
    final List<User> users = await getUsers() ?? [];

    // Verificar se já existe um usuário com mesmo username
    final existingIndex = users.indexWhere((u) => u.username == user.username);
    if (existingIndex >= 0) {
      users[existingIndex] = user; // Atualizar existente
    } else {
      users.add(user); // Adicionar novo
    }

    // Salvar lista atualizada
    final jsonString = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((json) => User.fromJson(json)).toList();
  }

  static Future<User?> getUserByUsername(String username) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.username == username);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
