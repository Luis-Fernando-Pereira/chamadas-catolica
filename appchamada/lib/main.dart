import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/model/class_room.dart';
import 'package:appchamada/model/course.dart';
import 'package:appchamada/model/lesson.dart';
import 'package:appchamada/model/lesson_status.dart';
import 'package:appchamada/model/student.dart';
import 'package:appchamada/model/subject.dart';
import 'package:appchamada/model/user.dart';
import 'package:appchamada/model/user_type.dart';
import 'package:appchamada/services/user_storage.dart';
import 'package:appchamada/provider/device_position_provider.dart';
import 'package:appchamada/screens/login_screen.dart';
import 'package:appchamada/services/lesson_storage.dart';
import 'package:appchamada/services/student_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final subject = Subject(id: 101, name: 'Matemática Discreta');

  // Criar a turma
  final assignedClass = AssignedClass(id: 5, name: 'Turma A - Noturno');

  // Criar a sala de aula
  final classRoom = ClassRoom(
    id: 12,
    name: 'Sala 301',
    position: Position(
      longitude: -48.8102047,
      latitude: -26.2391164,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 1.0,
      headingAccuracy: 1.0,
    ),
  );

  // Criar a aula
  final lesson = Lesson(
    id: 1001,
    start: DateTime.now().add(const Duration(hours: 1)), // começa em 1 hora
    duration: const Duration(hours: 2), // duração de 2 horas
    subject: subject,
    assignedClass: assignedClass,
    lessonStatus: LessonStatus.AGENDADO,
    classRoom: classRoom,
  );

  await LessonStorage.saveLessons([lesson]);

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

  // Criar usuário administrador mock
  final admin = User(
    id: 2,
    name: 'Administrador',
    username: 'admin', // username para login
    email: 'adm@email.com',
    password: 'admin123',
    isOnline: true,
    token: 'token_admin_123',
    userType: UserType.ADMIN,
  );

  // Salvar os usuários
  await StudentStorage.saveStudent(student);
  await UserStorage.saveUser(admin);

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
