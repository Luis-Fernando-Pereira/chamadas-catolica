import 'package:appchamada/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'provider/device_position_provider.dart';
import 'services/course_storage.dart';
import 'services/class_storage.dart';
import 'services/subject_storage.dart';
import 'services/class_room_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('✅ Firebase inicializado');
    await _seedInitialData();
  } catch (e) {
    print('❌ Erro: $e');
  }

  runApp(const MyApp());
}

Future<void> _seedInitialData() async {
  try {
    await _createDefaultAdmin();
    await CourseStorage.seedCoursesIfEmpty();
    await ClassStorage.seedClassesIfEmpty();
    await SubjectStorage.seedSubjectsIfEmpty();
    await ClassRoomStorage.seedClassRoomsIfEmpty();
    print('✅ Dados iniciais verificados');
  } catch (e) {
    print('⚠️ Erro seed: $e');
  }
}

Future<void> _createDefaultAdmin() async {
  try {
    final firestore = FirebaseFirestore.instance;

    final adminQuery = await firestore
        .collection('users')
        .where('username', isEqualTo: 'admin')
        .limit(1)
        .get();

    if (adminQuery.docs.isEmpty) {
      final password = 'admin';
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      await firestore.collection('users').add({
        'id': 999,
        'name': 'Administrador',
        'email': 'admin@catolica.edu.br',
        'username': 'admin',
        'password': hashedPassword,
        'userType': 'ADMIN',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Admin criado: admin/admin');
    } else {
      print('✅ Admin já existe');
    }
  } catch (e) {
    print('⚠️ Erro ao criar admin: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DevicePositionProvider(),
      child: MaterialApp(
        title: 'Chamada Automatizada',
        // ⬅️ ADICIONE ESTAS 3 LINHAS
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        locale: const Locale('pt', 'BR'),
        // ⬅️ FIM DAS LINHAS ADICIONADAS
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
