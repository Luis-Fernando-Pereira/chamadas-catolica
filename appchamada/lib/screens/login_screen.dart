import 'package:appchamada/model/logger.dart';
import 'package:appchamada/model/user.dart';
import 'package:appchamada/screens/dashboard_screen.dart';
import 'package:appchamada/screens/student_registration_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _performLogin() async {
    final logger = Logger();

    final username = _usernameController.text;
    final password = _passwordController.text;

    User? user = await logger.login(username, password);

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardScreen(loggedInUser: user),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insira usuário e senha para simular login.'),
        ),
      );
    }
  }

  void _goToRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StudentRegistrationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login - Chamada Automatizada')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // InputText: Nome de usuário
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nome de Usuário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // InputText: Senha
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            // Button: Entrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _performLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('ENTRAR', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            // Button: Cadastrar
            TextButton(
              onPressed: _goToRegistration,
              child: const Text('Cadastrar-se (Estudante)'),
            ),
          ],
        ),
      ),
    );
  }
}
