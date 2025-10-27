import 'package:flutter/material.dart';
import 'modules/auth/views/login_page.dart';
import 'modules/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Chamada',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {'/': (context) => const LoginPage()},
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as String?;
          return MaterialPageRoute(builder: (_) => HomePage(username: args));
        }
        return null;
      },
    );
  }
}
