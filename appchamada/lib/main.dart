import 'package:appchamada/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/course_storage.dart';
import 'services/class_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase
    await Firebase.initializeApp();
    print('✅ Firebase inicializado com sucesso');

    // Criar dados iniciais (cursos e turmas) se não existirem
    await _seedInitialData();
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e');
  }

  runApp(const MyApp());
}

/// Criar dados iniciais no Firebase (apenas na primeira execução)
Future<void> _seedInitialData() async {
  try {
    print('📦 Verificando dados iniciais...');

    // Criar cursos iniciais se não existirem
    await CourseStorage.seedCoursesIfEmpty();

    // Criar turmas iniciais se não existirem
    await ClassStorage.seedClassesIfEmpty();

    print('✅ Dados iniciais verificados!');
  } catch (e) {
    print('⚠️ Erro ao criar dados iniciais: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chamada Automatizada',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
