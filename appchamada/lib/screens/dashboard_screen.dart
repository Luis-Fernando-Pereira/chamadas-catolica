// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';

// PLACEHOLDERS: Você deve mover estas classes e enum para lib/model/
enum RollCallStatus { pending, active, closed }

class RollCallRound {
  final int roundNumber;
  RollCallStatus status;

  RollCallRound(this.roundNumber, {this.status = RollCallStatus.pending});
}
// FIM DOS PLACEHOLDERS

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<RollCallRound> _rounds = [];
  Map<int, bool> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _rounds = [
      RollCallRound(1, status: RollCallStatus.active),
      RollCallRound(2),
      RollCallRound(3),
      RollCallRound(4),
    ];
  }

  void _recordPresence(RollCallRound round) {
    if (round.status == RollCallStatus.active) {
      setState(() {
        _attendanceStatus[round.roundNumber] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Presença registrada na Rodada ${round.roundNumber}!'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A Rodada ${round.roundNumber} não está ativa.'))
      );
    }
  }

  Widget _buildRoundCard(RollCallRound round) {
    final bool isPresent = _attendanceStatus[round.roundNumber] ?? false;

    Color statusColor;
    String statusText;

    if (isPresent) {
      statusColor = Colors.green;
      statusText = 'PRESENTE (P)';
    } else if (round.status == RollCallStatus.active) {
      statusColor = Colors.blue;
      statusText = 'EM ANDAMENTO';
    } else if (round.status == RollCallStatus.closed) {
      statusColor = Colors.red;
      statusText = 'ENCERRADA';
    } else {
      statusColor = Colors.grey;
      statusText = 'A INICIAR';
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text('${round.roundNumber}', style: const TextStyle(color: Colors.white)),
        ),
        title: Text('Rodada ${round.roundNumber}'),
        subtitle: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        trailing: isPresent
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                onPressed: round.status == RollCallStatus.active
                    ? () => _recordPresence(round)
                    : null,
                child: const Text('Registrar'),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Chamadas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navegar para Histórico (Futuro)')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Status das 4 Rodadas de Hoje:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._rounds.map(_buildRoundCard).toList(),
            const SizedBox(height: 30),
            const Text(
              'Status Consolidado:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Presenças Registradas: ${_attendanceStatus.values.where((v) => v).length} de 4',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
             ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Layout CSV PREVISTO (Funcionalidade na N3)')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Prever Layout CSV'),
            ),
          ],
        ),
      ),
    );
  }
}