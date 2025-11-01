import 'dart:convert';
import 'dart:math';
import 'administrator.dart';
import 'user_type.dart';
import 'package:appchamada/model/student.dart';
import 'package:appchamada/services/student_storage.dart';
import 'user.dart';

class Logger {
  void logout(User user) {
    user.isOnline = false;
    user.token = null;
  }

  Future<User?> login(String username, String password) async {
    if (username == 'admin' && password == 'admin') {
      return Administrator.user(
        id: 999,
        name: 'Administrador',
        username: 'admin',
        email: 'admin@catolica.edu.br',
        userType: UserType.ADMIN,
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

    return null;
  }

  String _generateToken() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(values);
  }
}
