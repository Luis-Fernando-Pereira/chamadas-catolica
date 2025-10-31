// lib/screens/perfil_screen.dart

import 'package:flutter/material.dart';
// Certifique-se de importar sua LoginScreen real aqui
// import 'login_screen.dart';


class PerfilScreen extends StatelessWidget { 
  final Map<String, String> user;

  const PerfilScreen({super.key, required this.user});

  void _performLogout(BuildContext context) {
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreenPlaceholder()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: user['type'] == 'Professor' ? Colors.deepPurple : Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: user['type'] == 'Professor' ? Colors.deepPurple : Colors.blue,
              child: Text(user['type']![0], style: const TextStyle(fontSize: 40, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Text(
              user['name'] ?? 'Nome Não Informado',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Tipo de Usuário: ${user['type']}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Matrícula/ID'),
              subtitle: Text(user['id'] ?? 'N/A'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nome de Usuário'),
              subtitle: Text(user['username'] ?? 'N/A'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _performLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Sair (Logout)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder da tela de Login para garantir a compilação
class LoginScreenPlaceholder extends StatelessWidget {
  const LoginScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('LoginScreen (Pós Logout)')));
}