// lib/screens/registration_screen.dart

import 'package:appchamada/model/assigned_class.dart';
import 'package:flutter/material.dart';

// Importando os modelos necessários
import '../model/student.dart';
import '../model/course.dart';

// O nome da classe é RegistrationScreen para combinar com o que a LoginScreen espera
class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _semesterController = TextEditingController();

  Course? _selectedCourse;
  AssignedClass? _selectedClass;

  // --- DADOS SIMULADOS (MOCK) ---
  final List<Course> _courses = [
    Course(id: 1, name: 'Engenharia de Software'),
    Course(id: 2, name: 'Ciência da Computação'),
    Course(id: 3, name: 'Sistemas de Informação'),
  ];

  final List<AssignedClass> _classes = [
    AssignedClass(id: 101, name: 'Turma 2025/1'),
    AssignedClass(id: 102, name: 'Turma 2025/2'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newStudent = Student(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text,
        email: _emailController.text,
        username:
            _emailController.text, // Usando email como username por padrão
        password: _passwordController.text,
        semester: int.tryParse(_semesterController.text) ?? 1,
        course: _selectedCourse,
        assignedClass: _selectedClass,
        isOnline: false,
      );

      // TODO: Salvar o 'newStudent' no banco de dados.

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aluno "${newStudent.name}" cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Volta para a tela anterior (Login) após o sucesso.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Novo Aluno')),
      body: Form(
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
                // Estilo consistente com a tela de Login
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
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
                validator: (value) => (value == null || !value.contains('@'))
                    ? 'Insira um e-mail válido.'
                    : null,
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
                items: _courses
                    .map(
                      (course) => DropdownMenuItem(
                        value: course,
                        child: Text(course.name!),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedCourse = value),
                validator: (value) =>
                    value == null ? 'Selecione um curso.' : null,
              ),
              const SizedBox(height: 20),

              // --- DROPDOWN TURMA ---
              DropdownButtonFormField<AssignedClass>(
                initialValue: _selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Turma',
                  border: OutlineInputBorder(),
                ),
                items: _classes
                    .map(
                      (turma) => DropdownMenuItem(
                        value: turma,
                        child: Text(turma.name!),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedClass = value),
                validator: (value) =>
                    value == null ? 'Selecione uma turma.' : null,
              ),
              const SizedBox(height: 30),

              // --- BOTÃO DE SUBMISSÃO ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
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
