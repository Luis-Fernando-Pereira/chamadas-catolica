// lib/screens/dashboard_screen.dart

import 'package:appchamada/model/administrator.dart';
import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/model/professor.dart';
import 'package:appchamada/model/student.dart';
import 'package:appchamada/provider/device_position_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// Importando os modelos que criamos
import '../model/user.dart';
import '../model/user_type.dart';
// ... outros modelos que você precisar

// Classes de placeholder movidas do código original. O ideal é movê-las para /model
enum RollCallStatus { pending, active, closed }

class RollCallRound extends Container {
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
    
  Student? student;
  Professor? professor;
  Administrator? administrator;

  List<RollCallRound> _rounds = [];
  Map<int, bool> _attendanceStatus = {};

  Future<void> _handleLocationSetup() async {
    var status = await Permission.location.status;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }

    final positionProvider = context.read<DevicePositionProvider>();
    await positionProvider.determinePosition();

    print('Posição inicial: ${positionProvider.position}');
  }


  @override
  void initState() {
    super.initState();    
    
    switch(widget.loggedInUser.userType) {
      case UserType.STUDENT:
        student = Student(id: 1);
        student?.assignedClass = AssignedClass(id: 1);
        break;

      default:
        break;
    }

    _rounds = [
      RollCallRound(1, status: RollCallStatus.active),
      RollCallRound(2),
      RollCallRound(3),
      RollCallRound(4),
    ];    
  }

  // Método para registrar presença (do código do seu colega)
  void _recordPresence(RollCallRound round) {
    print('REGISTRANDO PRESENÇA');
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
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () => Navigator.pop(context),
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
                onPressed: () async {
                  await _handleLocationSetup();

                  final currentPosition = context.read<DevicePositionProvider>().position;
                  if (currentPosition == null) {
                    print("Erro ao obter localização.");
                    return;
                  }

                  //TODO: trocar esta longitude e latitude pela da sala de aula registrada no banco de dados
                  const targetLatitude = -26.2494107;
                  const targetLongitude = -48.8160327 ;

                  final distanceInMeters = Geolocator.distanceBetween(
                    currentPosition.latitude,
                    currentPosition.longitude,
                    targetLatitude,
                    targetLongitude,
                  );

                  print("Distância até o destino: ${distanceInMeters.toStringAsFixed(2)} m");

                  if (distanceInMeters <= 5) {
                    if (round.status == RollCallStatus.active) {
                      _recordPresence(round);
                    } else {
                      print("Rodada não está ativa.");
                    }
                  } else {
                    print("Usuário não está próximo o suficiente.");
                  }
                },
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
    return const Center(child: Text('Visão do Administrador em construção.'));
  }
}
