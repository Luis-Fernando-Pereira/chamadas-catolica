// lib/screens/registro_professor_screen.dart

import 'package:flutter/material.dart';


class AppData {
  static List<Map<String, String>> registeredUsers = [];
}

class RegistroProfessorScreen extends StatefulWidget { 
  const RegistroProfessorScreen({super.key});

  @override
  State<RegistroProfessorScreen> createState() => _RegistroProfessorScreenState();
}

class _RegistroProfessorScreenState extends State<RegistroProfessorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _performRegistration() {
    final name = _nameController.text;
    final id = _idController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (name.isNotEmpty && id.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {

      // Simulação do registro em memória
      AppData.registeredUsers.add({
        'type': 'Professor',
        'name': name,
        'id': id,
        'username': username,
        'password': password,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Professor cadastrado com sucesso (Simulado)!')),
      );

      // Volta para a tela de Login
      Navigator.of(context).pop();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Professor'), // Título da tela ajustado
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome Completo'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Matrícula/ID'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nome de Usuário'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _performRegistration,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('CADASTRAR', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}