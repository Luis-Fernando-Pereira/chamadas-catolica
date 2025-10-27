import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String? username;
  const HomePage({Key? key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name =
        username ??
        ModalRoute.of(context)?.settings.arguments as String? ??
        'Usuário';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // voltar para login (remover todas as rotas)
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Bem-vindo, $name!', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
