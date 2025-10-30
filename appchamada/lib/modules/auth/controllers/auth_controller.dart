import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthController {
  static const _usersKey = 'auth_users';

  Future<List<UserModel>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }

  Future<bool> register(UserModel user) async {
    final users = await _loadUsers();
    final exists = users.any((u) => u.username == user.username);
    if (exists) return false; // usuário já existe
    users.add(user);
    await _saveUsers(users);
    return true;
  }

  Future<bool> login(String username, String password) async {
    final users = await _loadUsers();
    final found = users.firstWhere(
      (u) => u.username == username && u.password == password,
      orElse: () => UserModel(username: '', password: ''),
    );
    return found.username.isNotEmpty;
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
