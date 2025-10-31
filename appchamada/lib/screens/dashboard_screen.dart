// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';

// Importando os modelos que criamos
import '../model/user.dart';
import '../model/user_type.dart';
import 'reports_screen.dart';
// ... outros modelos que você precisar

// Classes de placeholder movidas do código original. O ideal é movê-las para /model
enum RollCallStatus { pending, active, closed }

class RollCallRound {
  final int roundNumber;
  final RollCallStatus status;

  RollCallRound(this.roundNumber, {this.status = RollCallStatus.pending});
}
// Fim dos placeholders

class DashboardScreen extends StatefulWidget {
  final User loggedInUser;
  const DashboardScreen({super.key, required this.loggedInUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variáveis de estado trazidas do código do seu colega
  List<RollCallRound> _rounds = [];
  Map<int, bool> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    // Lógica de inicialização das rodadas
    _rounds = [
      RollCallRound(1, status: RollCallStatus.active),
      RollCallRound(2),
      RollCallRound(3),
      RollCallRound(4),
    ];
  }

  // Método para registrar presença (do código do seu colega)
  void _recordPresence(RollCallRound round) {
    if (round.status == RollCallStatus.active) {
      setState(() {
        _attendanceStatus[round.roundNumber] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Presença registrada na Rodada ${round.roundNumber}!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A Rodada ${round.roundNumber} não está ativa.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usando a estrutura de Scaffold e Drawer que eu propus
    return Scaffold(
      appBar: AppBar(title: const Text('Painel de Chamadas')),
      drawer: _buildAppDrawer(), // Menu lateral
      body: _buildDashboardBody(), // Corpo dinâmico baseado no usuário
    );
  }

  // O menu lateral continua o mesmo
  Widget _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              'Olá, ${widget.loggedInUser.name ?? 'Usuário'}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Relatórios'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ReportsScreen(loggedInUser: widget.loggedInUser),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  // A lógica principal de troca de view continua a mesma
  Widget _buildDashboardBody() {
    switch (widget.loggedInUser.userType) {
      case UserType.STUDENT:
        return _buildStudentView(); // Esta view agora será muito mais completa
      case UserType.PROFESSOR:
        return _buildProfessorView();
      case UserType.ADMIN:
        return _buildAdminView();
      default:
        return const Center(child: Text('Tipo de usuário inválido.'));
    }
  }

  // --- NOVA VIEW DO ALUNO (MESCLADA) ---
  Widget _buildStudentView() {
    // Esta é a estrutura do body do código do seu colega
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Status das 4 Rodadas de Hoje:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Mapeia a lista de rodadas para a lista de widgets de card
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
        ],
      ),
    );
  }

  // O card de rodada (do código do seu colega)
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
      statusText = 'FALTA (F)'; // Ajuste para mais clareza
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
          child: Text(
            '${round.roundNumber}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text('Rodada ${round.roundNumber}'),
        subtitle: Text(
          statusText,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
        trailing: isPresent
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                // Habilita o botão apenas se a rodada estiver ativa
                onPressed: round.status == RollCallStatus.active
                    ? () => _recordPresence(round)
                    : null,
                child: const Text('Registrar'),
              ),
      ),
    );
  }

  // As views de Professor e Admin podem ser as que eu sugeri anteriormente
  Widget _buildProfessorView() {
    return const Center(child: Text('Visão do Professor em construção.'));
  }

  Widget _buildAdminView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text('Gerenciar Salas'),
              subtitle: const Text('Cadastrar e gerenciar salas de aula'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Gerenciar Alunos'),
              subtitle: const Text('Cadastrar e gerenciar alunos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
