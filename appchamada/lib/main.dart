// lib/main.dart

import 'package:flutter/material.dart';
// Importe a sua tela de login para que possamos usá-la como tela inicial.
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Católica Chamadas',
      theme: ThemeData(
        // O tema pode ser ajustado para combinar com o design que vocês definirem.
        // Vamos usar o tema padrão azul por enquanto.
        primarySwatch: Colors.blue,
        // Usando bordas nos campos de texto para combinar com a LoginScreen
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // A 'home' é a primeira tela a ser exibida. Deve ser a LoginScreen.
      home: const LoginScreen(),
    );
  }
}
