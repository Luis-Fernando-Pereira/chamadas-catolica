import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/model/course.dart';
import 'package:appchamada/model/student.dart';
import 'package:appchamada/model/user_type.dart';
import 'package:appchamada/provider/device_position_provider.dart';
import 'package:appchamada/screens/login_screen.dart';
import 'package:appchamada/services/student_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final student = Student(
    id: 1,
    name: 'Fernando Costa',
    username: 'teste',
    email: 'fernando.costa@catolica.edu.br',
    password: '123',
    isOnline: true,
    token: 'token_abc_123',
    course: Course(id: 10, name: 'Engenharia de Software'),
    assignedClass: AssignedClass(id: 5, name: 'Turma A - Noturno'),
    semester: 6,
  );

  student.userType = UserType.STUDENT;

  await StudentStorage.saveStudent(student);

  final loaded = await StudentStorage.getStudent();
  print('Aluno carregado: ${loaded?.name}, ${loaded?.userType?.name}');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DevicePositionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}