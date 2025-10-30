// lib/screens/login_screen.dart

import 'package:flutter/material.dart';

// O DashboardScreen e RegistrationScreen devem ser criados separadamente.
// Importe eles aqui quando estiverem prontos.
// import 'dashboard_screen.dart';
// import 'registration_screen.dart'; 

// Classes de placeholder para garantir que o código compile para demonstração:
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Dashboard das 4 Rodadas (Navegável)')));
}

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Tela de Cadastro de Estudante (Navegável)')));
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _performLogin() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    
    // Simulação da lógica de login (Em Memória - N2)
    // Apenas verifica se os campos não estão vazios para permitir a navegação.
    
    if (username.isNotEmpty && password.isNotEmpty) {
        // Navegação para a tela principal (Dashboard das 4 Rodadas)
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
    } else {
      // Feedback visual simples para simulação
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insira usuário e senha para simular login.')),
      );
    }
  }

  void _goToRegistration() {
    // Navegação para a tela de cadastro de estudante
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
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