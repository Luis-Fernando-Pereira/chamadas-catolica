import 'package:flutter/material.dart';
import '../services/roll_call_storage.dart';
import '../model/roll_call.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Presenças')),
      body: FutureBuilder<List<RollCall>?>(
        future: RollCallStorage.getRollCalls(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rollCalls = snapshot.data ?? [];

          if (rollCalls.isEmpty) {
            return const Center(
              child: Text('Nenhum registro de presença ainda'),
            );
          }

          return ListView.builder(
            itemCount: rollCalls.length,
            itemBuilder: (context, index) {
              final rc = rollCalls[index];
              final status = rc.presence ? 'PRESENTE' : 'FALTA';
              final color = rc.presence ? Colors.green : Colors.red;

              final recordedTime = rc.recordedAt != null
                  ? rc.recordedAt!.toString().substring(11, 19)
                  : 'N/A';
              final lessonDate = rc.lesson.start != null
                  ? rc.lesson.start!.toString().substring(0, 10)
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    rc.presence ? Icons.check_circle : Icons.cancel,
                    color: color,
                    size: 32,
                  ),
                  title: Text(rc.lesson.subject?.name ?? 'Matéria'),
                  subtitle: Text(
                    'Data: $lessonDate\n'
                    'Rodada ${index + 1}\n'
                    'Registrado às: $recordedTime',
                  ),
                  trailing: Chip(
                    label: Text(status),
                    backgroundColor: color.withValues(alpha: 0.2),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
