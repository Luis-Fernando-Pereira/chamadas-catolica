// lib/model/logger.dart

import 'dart:convert';
import 'dart:math'; // Usado para gerar um token aleatório simples.
import 'administrator.dart';
import 'user_type.dart';
// --- DEPENDÊNCIAS ---
// Para este código funcionar sem erros, as seguintes classes precisam existir.
// Por enquanto, os imports e o código que depende delas ficarão comentados.
import 'package:appchamada/model/student.dart';
import 'package:appchamada/services/student_storage.dart';
import 'package:appchamada/services/user_storage.dart';
import 'user.dart';
// import 'student.dart';
// import 'professor.dart';
// import 'administrator.dart';

class Logger {
  void logout(User user) {
    user.isOnline = false;
    user.token = null;

    print('Usuário ${user.username} deslogado com sucesso.');
  }

  /// Valida as credenciais e retorna o usuário correspondente se forem válidas.
  /// Retorna um objeto do tipo User (Student, Professor, etc.) em caso de sucesso,
  /// ou null em caso de falha.
  Future<User?> login(String username, String password) async {
    print('Tentando login com usuário: $username');

    if (username == 'admin' && password == 'admin') {
      print('Login de Administrador bem-sucedido!');

      // Agora usamos o construtor nomeado 'Administrator.user', que acabamos de corrigir.
      // Ele aceita todos os parâmetros de uma vez.
      return Administrator.user(
        id: 999,
        name: 'Administrador',
        username: 'admin',
        email: 'admin@catolica.edu.br',
        userType: UserType.ADMIN, // Passando o userType diretamente
        isOnline: true,
      );
    }

    Student? student = await StudentStorage.getStudent();

    if (student != null &&
        student.username == username &&
        student.password == password) {
      return User(
        id: student.id,
        email: student.email,
        isOnline: true,
        name: student.name,
        password: password,
        token: _generateToken(),
        userType: student.userType,
        username: username,
      );
    }

    /*
    // Lista de usuários de exemplo
    final List<User> mockUsers = [
      Student(id: 101, username: 'aluno', password: '123', name: 'Miguel Aluno', email: 'miguel@aluno.com', semester: 2),
      Professor(id: 202, username: 'prof', password: '456', name: 'Leonardo Professor', email: 'leo@prof.com', actingField: 'Engenharia de Software'),
      Administrator(id: 303, username: 'admin', password: '789', name: 'Luis Admin', email: 'luis@admin.com'),
    ];

    // Busca pelo usuário na nossa lista simulada
    try {
      final user = mockUsers.firstWhere(
        (user) => user.username == username && user.password == password,
      );

      // Se encontrou o usuário, atualiza seu status e gera um token
      user.isOnline = true;
      user.token = _generateToken(); // Gera um token aleatório
      print('Login bem-sucedido para: ${user.name}');
      return user; // Retorna o objeto do usuário encontrado

    } catch (e) {
      // O 'firstWhere' lança uma exceção se não encontrar ninguém,
      // então usamos o catch para lidar com o login inválido.
      print('Falha no login: usuário ou senha inválidos.');
      return null; // Retorna null para indicar que o login falhou
    }
    */

    return null;
  }

  String _generateToken() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(values);
  }
}
