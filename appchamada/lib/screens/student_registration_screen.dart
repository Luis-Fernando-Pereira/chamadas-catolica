// lib/screens/student_registration_screen.dart

import 'package:appchamada/model/assigned_class.dart';
import 'package:flutter/material.dart';

// Importando os modelos necessários
import '../model/student.dart';
import '../model/course.dart';
import '../services/auth_service.dart';
import '../services/course_storage.dart';
import '../services/class_storage.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _semesterController = TextEditingController();

  Course? _selectedCourse;
  AssignedClass? _selectedClass;
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Dados carregados do Firebase
  List<Course> _courses = [];
  List<AssignedClass> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carregar cursos e turmas do Firebase
  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    try {
      // Buscar cursos do Firebase
      final courses = await CourseStorage.getCourses();

      // Buscar turmas do Firebase
      final classes = await ClassStorage.getClasses();

      if (mounted) {
        setState(() {
          _courses = courses;
          _classes = classes;
          _isLoadingData = false;
        });
      }

      print(
        '✅ Dados carregados: ${courses.length} cursos, ${classes.length} turmas',
      );
    } catch (e) {
      print('❌ Erro ao carregar dados: $e');

      if (mounted) {
        setState(() => _isLoadingData = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Cadastrar aluno no Firebase
      final result = await AuthService.registerStudent(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        semester: int.tryParse(_semesterController.text) ?? 1,
        courseId: _selectedCourse?.id,
        classId: _selectedClass?.id,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success']) {
          // Sucesso - Mostrar mensagem e voltar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );

          // Voltar para a tela de login
          Navigator.of(context).pop();
        } else {
          // Erro - Mostrar mensagem
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Novo Aluno')),
      body: _isLoadingData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando dados...'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 10),

                    // --- CAMPO NOME ---
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'O nome é obrigatório.'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // --- CAMPO E-MAIL ---
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail Acadêmico',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          (value == null || !value.contains('@'))
                          ? 'Insira um e-mail válido.'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // --- CAMPO USERNAME ---
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome de Usuário',
                        border: OutlineInputBorder(),
                        hintText: 'Usado para fazer login',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'O nome de usuário é obrigatório.';
                        }
                        if (value.contains(' ')) {
                          return 'Nome de usuário não pode conter espaços.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- CAMPO SENHA ---
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) => (value == null || value.length < 6)
                          ? 'A senha deve ter no mínimo 6 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // --- CAMPO SEMESTRE ---
                    TextFormField(
                      controller: _semesterController,
                      decoration: const InputDecoration(
                        labelText: 'Semestre Atual',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          (value == null || int.tryParse(value) == null)
                          ? 'Insira um número válido.'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // --- DROPDOWN CURSO ---
                    DropdownButtonFormField<Course>(
                      value: _selectedCourse,
                      decoration: const InputDecoration(
                        labelText: 'Curso',
                        border: OutlineInputBorder(),
                      ),
                      items: _courses.isEmpty
                          ? [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Nenhum curso disponível'),
                              ),
                            ]
                          : _courses
                                .map(
                                  (course) => DropdownMenuItem(
                                    value: course,
                                    child: Text(course.name!),
                                  ),
                                )
                                .toList(),
                      onChanged: _courses.isEmpty
                          ? null
                          : (value) => setState(() => _selectedCourse = value),
                      validator: (value) =>
                          value == null ? 'Selecione um curso.' : null,
                    ),
                    const SizedBox(height: 20),

                    // --- DROPDOWN TURMA ---
                    DropdownButtonFormField<AssignedClass>(
                      value: _selectedClass,
                      decoration: const InputDecoration(
                        labelText: 'Turma',
                        border: OutlineInputBorder(),
                      ),
                      items: _classes.isEmpty
                          ? [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Nenhuma turma disponível'),
                              ),
                            ]
                          : _classes
                                .map(
                                  (turma) => DropdownMenuItem(
                                    value: turma,
                                    child: Text(turma.name!),
                                  ),
                                )
                                .toList(),
                      onChanged: _classes.isEmpty
                          ? null
                          : (value) => setState(() => _selectedClass = value),
                      validator: (value) =>
                          value == null ? 'Selecione uma turma.' : null,
                    ),
                    const SizedBox(height: 30),

                    // --- BOTÃO DE SUBMISSÃO ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'CADASTRAR',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
