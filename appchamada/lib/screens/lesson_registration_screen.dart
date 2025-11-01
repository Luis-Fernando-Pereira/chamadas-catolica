// lib/screens/lesson_registration_screen.dart

import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/model/class_room.dart';
import 'package:appchamada/model/lesson.dart';
import 'package:appchamada/model/lesson_status.dart';
import 'package:appchamada/model/subject.dart';
import 'package:appchamada/services/lesson_storage.dart';
import 'package:flutter/material.dart';

class LessonRegistrationScreen extends StatefulWidget {
  const LessonRegistrationScreen({super.key});

  @override
  State<LessonRegistrationScreen> createState() =>
      _LessonRegistrationScreenState();
}

class _LessonRegistrationScreenState extends State<LessonRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();

  // Variáveis para os selecionadores
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Subject? _selectedSubject;
  AssignedClass? _selectedClass;
  ClassRoom? _selectedClassRoom;
  LessonStatus _selectedStatus = LessonStatus.AGENDADO; // Valor padrão

  // --- DADOS SIMULADOS (MOCK) ---
  // Em um app real, estes dados viriam de um banco de dados
  final List<Subject> _subjects = [
    Subject(id: 1, name: 'Desenvolvimento Mobile'),
    Subject(id: 2, name: 'Engenharia de Requisitos'),
    Subject(id: 3, name: 'Qualidade de Software'),
  ];
  final List<AssignedClass> _classes = [
    AssignedClass(id: 101, name: 'Turma 2025/1 - Noturno'),
    AssignedClass(id: 102, name: 'Turma 2025/2 - Vespertino'),
  ];
  final List<ClassRoom> _classRooms = [
    ClassRoom(id: 201, name: 'Sala 301 - Bloco C'),
    ClassRoom(id: 202, name: 'Laboratório A'),
  ];

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  // Função para abrir o seletor de data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Função para abrir o seletor de hora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione data e hora.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Combina data e hora em um único objeto DateTime
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final newLesson = Lesson(
        id: DateTime.now().millisecondsSinceEpoch,
        start: startDateTime,
        duration: Duration(minutes: int.parse(_durationController.text)),
        subject: _selectedSubject,
        assignedClass: _selectedClass,
        classRoom: _selectedClassRoom,
        lessonStatus: _selectedStatus,
      );

      // Lógica de salvamento
      final existingLessons = await LessonStorage.getLessons() ?? [];
      existingLessons.add(newLesson);
      await LessonStorage.saveLessons(
        existingLessons,
      ); // Usando o método corrigido

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aula cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Nova Aula')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SELETORES DE DATA E HORA ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDate == null
                            ? 'Selecionar Data'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      ),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _selectedTime == null
                            ? 'Selecionar Hora'
                            : _selectedTime!.format(context),
                      ),
                      onPressed: () => _selectTime(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- DROPDOWN DE MATÉRIA ---
              DropdownButtonFormField<Subject>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Matéria',
                  border: OutlineInputBorder(),
                ),
                items: _subjects
                    .map(
                      (subject) => DropdownMenuItem(
                        value: subject,
                        child: Text(subject.name!),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedSubject = value),
                validator: (value) =>
                    value == null ? 'Selecione uma matéria.' : null,
              ),
              const SizedBox(height: 20),

              // --- DROPDOWN DE TURMA ---
              DropdownButtonFormField<AssignedClass>(
                value: _selectedClass,
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
              const SizedBox(height: 20),

              // --- DROPDOWN DE SALA ---
              DropdownButtonFormField<ClassRoom>(
                value: _selectedClassRoom,
                decoration: const InputDecoration(
                  labelText: 'Sala de Aula',
                  border: OutlineInputBorder(),
                ),
                items: _classRooms
                    .map(
                      (room) => DropdownMenuItem(
                        value: room,
                        child: Text(room.name!),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedClassRoom = value),
                validator: (value) =>
                    value == null ? 'Selecione uma sala.' : null,
              ),
              const SizedBox(height: 20),

              // --- DROPDOWN DE STATUS ---
              DropdownButtonFormField<LessonStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status da Aula',
                  border: OutlineInputBorder(),
                ),
                items: LessonStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
              const SizedBox(height: 20),

              // --- CAMPO DE DURAÇÃO ---
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duração (em minutos)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value == null || int.tryParse(value) == null)
                    ? 'Insira um número válido.'
                    : null,
              ),
              const SizedBox(height: 30),

              // --- BOTÃO DE CADASTRAR ---
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'CADASTRAR AULA',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
