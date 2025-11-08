import 'dart:convert';
import 'dart:math';
import 'administrator.dart';
import 'user_type.dart';
import 'package:appchamada/model/student.dart';
import 'package:appchamada/services/auth_service.dart';
import 'user.dart';

class Logger {
  void logout(User user) {
    user.isOnline = false;
    user.token = null;
  }

  Future<User?> login(String username, String password) async {
    try {
      print('🔐 Logger: Tentando login com Firebase...');

      // Tentar login via Firebase
      final result = await AuthService.login(
        username: username,
        password: password,
      );

      if (result['success']) {
        print('✅ Logger: Login bem-sucedido via Firebase');

        final User user = result['user'];
        user.token = _generateToken();

        return user;
      } else {
        print('❌ Logger: ${result['message']}');
        return null;
      }
    } catch (e) {
      print('❌ Logger: Erro ao fazer login: $e');

      // Fallback: Admin hardcoded (apenas para emergência)
      if (username == 'admin' && password == 'admin') {
        print('⚠️ Logger: Usando admin hardcoded (fallback)');
        return Administrator.user(
          id: 999,
          name: 'Administrador',
          username: 'admin',
          email: 'admin@catolica.edu.br',
          userType: UserType.ADMIN,
          isOnline: true,
        );
      }

      return null;
    }
  }

  String _generateToken() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(values);
  }
}
