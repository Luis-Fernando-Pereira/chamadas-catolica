// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../model/user.dart';
import '../model/user_type.dart';
import '../model/student.dart';

class AuthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  /// Hash de senha usando SHA256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Registrar novo aluno
  static Future<Map<String, dynamic>> registerStudent({
    required String name,
    required String email,
    required String username,
    required String password,
    required int semester,
    int? courseId,
    int? classId,
  }) async {
    try {
      // Verificar se username já existe
      final existingUser = await _firestore
          .collection(_usersCollection)
          .where('username', isEqualTo: username)
          .get();

      if (existingUser.docs.isNotEmpty) {
        return {'success': false, 'message': 'Nome de usuário já está em uso'};
      }

      // Verificar se email já existe
      final existingEmail = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .get();

      if (existingEmail.docs.isNotEmpty) {
        return {'success': false, 'message': 'Email já está cadastrado'};
      }

      // Gerar ID único para o aluno
      final studentId = DateTime.now().millisecondsSinceEpoch;

      // Criar documento do usuário
      final userDoc = _firestore.collection(_usersCollection).doc();

      final userData = {
        'id': studentId,
        'name': name,
        'email': email,
        'username': username,
        'password': _hashPassword(password),
        'userType': 'STUDENT',
        'semester': semester,
        'courseId': courseId,
        'classId': classId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await userDoc.set(userData);

      print('✅ Aluno cadastrado no Firebase: $name');

      return {
        'success': true,
        'message': 'Aluno cadastrado com sucesso!',
        'studentId': studentId,
      };
    } catch (e) {
      print('❌ Erro ao cadastrar aluno: $e');
      return {'success': false, 'message': 'Erro ao cadastrar aluno: $e'};
    }
  }

  /// Login de usuário
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      print('🔍 Tentando login: $username');

      // Buscar usuário por username
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ Usuário não encontrado: $username');
        return {'success': false, 'message': 'Usuário não encontrado'};
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();

      // Verificar senha
      final hashedPassword = _hashPassword(password);
      if (userData['password'] != hashedPassword) {
        print('❌ Senha incorreta para: $username');
        return {'success': false, 'message': 'Senha incorreta'};
      }

      print('✅ Login bem-sucedido: $username');

      // Converter para objeto User
      final user = User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        username: userData['username'],
        userType: _parseUserType(userData['userType']),
        isOnline: true,
      );

      return {
        'success': true,
        'message': 'Login realizado com sucesso!',
        'user': user,
        'userData': userData, // Dados completos para uso posterior
      };
    } catch (e) {
      print('❌ Erro ao fazer login: $e');
      return {'success': false, 'message': 'Erro ao fazer login: $e'};
    }
  }

  /// Converter string para UserType
  static UserType _parseUserType(String typeString) {
    switch (typeString) {
      case 'STUDENT':
        return UserType.STUDENT;
      case 'PROFESSOR':
        return UserType.PROFESSOR;
      case 'ADMIN':
        return UserType.ADMIN;
      default:
        return UserType.STUDENT;
    }
  }

  /// Verificar se existe algum admin no sistema
  static Future<bool> hasAdmin() async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('userType', isEqualTo: 'ADMIN')
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Erro ao verificar admin: $e');
      return false;
    }
  }

  /// Criar primeiro admin (usado apenas na primeira execução)
  static Future<Map<String, dynamic>> createFirstAdmin({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // Verificar se já existe admin
      final adminExists = await hasAdmin();
      if (adminExists) {
        return {
          'success': false,
          'message': 'Já existe um administrador no sistema',
        };
      }

      // Criar admin
      final userDoc = _firestore.collection(_usersCollection).doc();

      final userData = {
        'id': 999, // ID fixo para admin
        'name': name,
        'email': email,
        'username': username,
        'password': _hashPassword(password),
        'userType': 'ADMIN',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await userDoc.set(userData);

      print('✅ Admin criado com sucesso: $name');

      return {'success': true, 'message': 'Administrador criado com sucesso!'};
    } catch (e) {
      print('❌ Erro ao criar admin: $e');
      return {'success': false, 'message': 'Erro ao criar admin: $e'};
    }
  }
}
