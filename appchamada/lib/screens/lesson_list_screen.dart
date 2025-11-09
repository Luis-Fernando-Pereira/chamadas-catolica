// lib/screens/lesson_list_screen.dart
import 'package:appchamada/model/lesson.dart';
import 'package:appchamada/services/lesson_storage.dart';
import 'package:flutter/material.dart';
import 'lesson_registration_screen.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  late Future<List<Lesson>?> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _lessonsFuture = LessonStorage.getLessons();
  }

  Future<void> _refresh() async {
    setState(() {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aulas Cadastradas')),
      body: FutureBuilder<List<Lesson>?>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lessons = snapshot.data ?? [];

          if (lessons.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Nenhuma aula cadastrada'),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final dateStr = lesson.start != null
                    ? '${lesson.start!.day}/${lesson.start!.month}/${lesson.start!.year} ${lesson.start!.hour}:${lesson.start!.minute.toString().padLeft(2, '0')}'
                    : 'Sem data';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        lesson.subject?.name?.substring(0, 1) ?? 'A',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(lesson.subject?.name ?? 'Matéria'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Turma: ${lesson.assignedClass?.name ?? "—"}'),
                        Text('Data: $dateStr'),
                        Text('Sala: ${lesson.classRoom?.name ?? "—"}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(lesson),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LessonRegistrationScreen()),
          );
          await _refresh();
        },
      ),
    );
  }

  Future<void> _confirmDelete(Lesson lesson) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir a aula de "${lesson.subject?.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await LessonStorage.deleteLesson(lesson.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aula excluída!'),
            backgroundColor: Colors.green,
          ),
        );
        await _refresh();
      }
    }
  }
}
