// lib/screens/course_list_screen.dart
import 'package:appchamada/model/course.dart';
import 'package:appchamada/services/course_storage.dart';
import 'package:flutter/material.dart';

import 'course_form_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late Future<List<Course>?> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _coursesFuture = CourseStorage.getCourses();
  }

  Future<void> _refresh() async {
    setState(() {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cursos')),
      body: FutureBuilder<List<Course>?>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  ListTile(title: Text('Nenhum curso cadastrado.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final c = courses[index];
                return ListTile(
                  title: Text(c.name ?? '—'),
                  subtitle: Text('ID: ${c.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CourseFormScreen(course: c),
                            ),
                          );
                          await _refresh();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirmar'),
                              content: const Text('Deseja excluir este curso?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Não'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Sim'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await CourseStorage.deleteCourse(c.id!);
                            await _refresh();
                          }
                        },
                      ),
                    ],
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
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CourseFormScreen()));
          await _refresh();
        },
      ),
    );
  }
}
