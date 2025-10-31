// lib/screens/course_form_screen.dart
import 'package:appchamada/model/course.dart';
import 'package:appchamada/services/course_storage.dart';
import 'package:flutter/material.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? course;
  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _nameController.text = widget.course!.name ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    if (widget.course != null) {
      final updated = Course(id: widget.course!.id!, name: name);
      await CourseStorage.updateCourse(updated);
    } else {
      // Simple id generation: timestamp in milliseconds
      final id = DateTime.now().millisecondsSinceEpoch % 1000000000;
      final newCourse = Course(id: id, name: name);
      await CourseStorage.saveCourse(newCourse);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Curso' : 'Novo Curso')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do curso'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o nome do curso'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Salvar' : 'Criar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
