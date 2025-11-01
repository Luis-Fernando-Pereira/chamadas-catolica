// lib/screens/subject_registration_screen.dart

import 'package:appchamada/model/subject.dart';
import 'package:appchamada/services/subject_storage.dart';
import 'package:flutter/material.dart';

class SubjectRegistrationScreen extends StatefulWidget {
  const SubjectRegistrationScreen({super.key});

  @override
  State<SubjectRegistrationScreen> createState() =>
      _SubjectRegistrationScreenState();
}

class _SubjectRegistrationScreenState extends State<SubjectRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newSubject = Subject(
        id: DateTime.now().millisecondsSinceEpoch, // ID único temporário
        name: _nameController.text,
      );

      // Lógica de salvamento
      final existingSubjects = await SubjectStorage.getSubjects() ?? [];
      existingSubjects.add(newSubject);
      await SubjectStorage.saveSubjects(existingSubjects);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matéria cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Nova Matéria')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // --- CAMPO NOME DA MATÉRIA ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Matéria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'O nome é obrigatório.'
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
                  'CADASTRAR MATÉRIA',
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
