// lib/screens/class_room_list_screen.dart
import 'package:appchamada/model/class_room.dart';
import 'package:appchamada/services/class_room_storage.dart';
import 'package:flutter/material.dart';
import 'class_room_form_screen.dart';

class ClassRoomListScreen extends StatefulWidget {
  const ClassRoomListScreen({super.key});

  @override
  State<ClassRoomListScreen> createState() => _ClassRoomListScreenState();
}

class _ClassRoomListScreenState extends State<ClassRoomListScreen> {
  late Future<List<ClassRoom>> _classRoomsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _classRoomsFuture = ClassRoomStorage.getClassRooms();
  }

  Future<void> _refresh() async {
    setState(() {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salas de Aula')),
      body: FutureBuilder<List<ClassRoom>>(
        future: _classRoomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final classRooms = snapshot.data ?? [];

          if (classRooms.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Nenhuma sala cadastrada'),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: classRooms.length,
              itemBuilder: (context, index) {
                final classRoom = classRooms[index];
                final hasLocation = classRoom.position != null;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: hasLocation
                          ? Colors.green
                          : Colors.orange,
                      child: Icon(
                        hasLocation ? Icons.location_on : Icons.location_off,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(classRoom.name ?? '—'),
                    subtitle: Text('ID: ${classRoom.id}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ClassRoomFormScreen(classRoom: classRoom),
                              ),
                            );
                            await _refresh();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(classRoom),
                        ),
                      ],
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
            MaterialPageRoute(builder: (_) => const ClassRoomFormScreen()),
          );
          await _refresh();
        },
      ),
    );
  }

  Future<void> _confirmDelete(ClassRoom classRoom) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir "${classRoom.name}"?'),
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
      await ClassRoomStorage.deleteClassRoom(classRoom.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sala excluída!'),
            backgroundColor: Colors.green,
          ),
        );
        await _refresh();
      }
    }
  }
}
