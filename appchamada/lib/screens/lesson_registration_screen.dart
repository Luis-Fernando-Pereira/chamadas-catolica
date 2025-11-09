// lib/screens/lesson_registration_screen.dart

import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/model/class_room.dart';
import 'package:appchamada/model/lesson.dart';
import 'package:appchamada/model/lesson_status.dart';
import 'package:appchamada/model/subject.dart';
import 'package:appchamada/services/lesson_storage.dart';
import 'package:appchamada/services/subject_storage.dart';
import 'package:appchamada/services/class_storage.dart';
import 'package:appchamada/services/class_room_storage.dart';
import 'package:flutter/material.dart';

class LessonRegistrationScreen extends StatefulWidget {
  const LessonRegistrationScreen({super.key});

  @override
  State<LessonRegistrationScreen> createState() =>
      _LessonRegistrationScreenState();
}

class _LessonRegistrationScreenState extends State<LessonRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _selectedDuration = 60;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Subject? _selectedSubject;
  AssignedClass? _selectedClass;
  ClassRoom? _selectedClassRoom;
  LessonStatus _selectedStatus = LessonStatus.AGENDADO;

  List<Subject> _subjects = [];
  List<AssignedClass> _classes = [];
  List<ClassRoom> _classRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final subjects = await SubjectStorage.getSubjects();
      final classes = await ClassStorage.getClasses();
      final classRooms = await ClassRoomStorage.getClassRooms();

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _classes = classes;
          _classRooms = classRooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

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
        duration: Duration(minutes: _selectedDuration),
        subject: _selectedSubject,
        assignedClass: _selectedClass,
        classRoom: _selectedClassRoom,
        lessonStatus: _selectedStatus,
      );

      await LessonStorage.saveLesson(newLesson);

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                      items: _subjects.isEmpty
                          ? [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Nenhuma matéria cadastrada'),
                              ),
                            ]
                          : _subjects
                                .map(
                                  (subject) => DropdownMenuItem(
                                    value: subject,
                                    child: Text(subject.name!),
                                  ),
                                )
                                .toList(),
                      onChanged: _subjects.isEmpty
                          ? null
                          : (value) => setState(() => _selectedSubject = value),
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
                      items: _classes.isEmpty
                          ? [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Nenhuma turma cadastrada'),
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
                    const SizedBox(height: 20),

                    // --- DROPDOWN DE SALA ---
                    DropdownButtonFormField<ClassRoom>(
                      value: _selectedClassRoom,
                      decoration: const InputDecoration(
                        labelText: 'Sala de Aula',
                        border: OutlineInputBorder(),
                      ),
                      items: _classRooms.isEmpty
                          ? [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Nenhuma sala cadastrada'),
                              ),
                            ]
                          : _classRooms
                                .map(
                                  (room) => DropdownMenuItem(
                                    value: room,
                                    child: Text(room.name!),
                                  ),
                                )
                                .toList(),
                      onChanged: _classRooms.isEmpty
                          ? null
                          : (value) =>
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
                      onChanged: (value) =>
                          setState(() => _selectedStatus = value!),
                    ),
                    const SizedBox(height: 20),

                    // --- DROPDOWN DE DURAÇÃO ---
                    DropdownButtonFormField<int>(
                      value: _selectedDuration,
                      decoration: const InputDecoration(
                        labelText: 'Duração',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 30, child: Text('30 minutos')),
                        DropdownMenuItem(value: 45, child: Text('45 minutos')),
                        DropdownMenuItem(
                          value: 60,
                          child: Text('1 hora (60 minutos)'),
                        ),
                        DropdownMenuItem(
                          value: 90,
                          child: Text('1h30 (90 minutos)'),
                        ),
                        DropdownMenuItem(
                          value: 120,
                          child: Text('2 horas (120 minutos)'),
                        ),
                        DropdownMenuItem(
                          value: 150,
                          child: Text('2h30 (150 minutos)'),
                        ),
                        DropdownMenuItem(
                          value: 180,
                          child: Text('3 horas (180 minutos)'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedDuration = value!),
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
