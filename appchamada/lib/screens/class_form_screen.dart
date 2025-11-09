// lib/screens/class_form_screen.dart
import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/services/class_storage.dart';
import 'package:flutter/material.dart';

class ClassFormScreen extends StatefulWidget {
  final AssignedClass? assignedClass;
  const ClassFormScreen({super.key, this.assignedClass});

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.assignedClass != null) {
      _nameController.text = widget.assignedClass!.name ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();

      if (widget.assignedClass != null) {
        final updated = AssignedClass(
          id: widget.assignedClass!.id!,
          name: name,
        );
        await ClassStorage.updateClass(updated);
      } else {
        final id = DateTime.now().millisecondsSinceEpoch % 1000000000;
        final newClass = AssignedClass(id: id, name: name);
        await ClassStorage.saveClass(newClass);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.assignedClass != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Turma' : 'Nova Turma')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Turma',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                  hintText: 'Ex: Turma 2025/1',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'SALVAR' : 'CRIAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
