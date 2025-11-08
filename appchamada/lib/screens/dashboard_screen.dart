// lib/screens/dashboard_screen.dart

import 'package:appchamada/model/administrator.dart';
import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/model/lesson.dart';
import 'package:appchamada/model/professor.dart';
import 'package:appchamada/model/roll_call.dart';
import 'package:appchamada/model/student.dart';
import 'package:appchamada/provider/device_position_provider.dart';
import 'package:appchamada/services/lesson_storage.dart';
import 'package:appchamada/services/roll_call_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'lesson_registration_screen.dart';
import 'subject_registration_screen.dart';
import 'history_screen.dart';
import '../services/consolidation_service.dart';
import '../services/csv_export_service.dart';
import '../widgets/sync_indicator.dart';
import 'login_screen.dart';

// Importando os modelos que criamos
import '../model/user.dart';
import '../model/user_type.dart';
import 'class_registration_screen.dart';
import 'course_list_screen.dart';
// ... outros modelos que você precisar

// Classes de placeholder movidas do código original. O ideal é movê-las para /model
enum RollCallStatus { pending, active, closed }

class RollCallRound extends Container {
  final int roundNumber;
  final RollCallStatus status;
  final Lesson lesson;

  RollCallRound(
    this.roundNumber, {
    super.key,
    this.status = RollCallStatus.pending,
    required this.lesson,
  });
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
  List<Lesson> lessons = [];

  List<RollCallRound> _rounds = [];
  final Map<int, bool> _attendanceStatus = {};

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

    switch (widget.loggedInUser.userType) {
      case UserType.STUDENT:
        student = Student(id: 1);
        student?.assignedClass = AssignedClass(id: 1);
        break;
      default:
        break;
    }

    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final loadedLessons = await LessonStorage.getLessons();
    setState(() {
      lessons = loadedLessons ?? [];
      _generateRollCallRounds();
    });

    // Atualiza a presença de acordo com os RollCalls salvos
    await _loadRollCallAttendance();
  }

  // Cria RollCallRounds dinamicamente a partir da lista de lessons
  void _generateRollCallRounds() {
    _rounds = lessons.asMap().entries.map((entry) {
      int index = entry.key;
      Lesson lesson = entry.value;

      // Você pode definir a primeira aula como ativa por exemplo
      RollCallStatus status = index == 0
          ? RollCallStatus.active
          : RollCallStatus.pending;

      return RollCallRound(index + 1, status: status, lesson: lesson);
    }).toList();
  }

  // Método para registrar presença (do código do seu colega)
  void _recordPresence(RollCallRound round) {
    print('REGISTRANDO PRESENÇA');
    if (round.status == RollCallStatus.active) {
      setState(() {
        RollCallStorage.saveRollCall(
          RollCall(
            id: DateTime.now()
                .millisecondsSinceEpoch, // ID único baseado em timestamp
            lesson: round.lesson,
            student: student!,
            presence: true,
            recordedAt: DateTime.now(), // Registra o momento exato da presença
          ),
        );

        _attendanceStatus[round.roundNumber] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Presença registrada na Rodada ${round.roundNumber}!'),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A Rodada ${round.roundNumber} não está ativa.'),
        ),
      );
    }
  }

  Future<void> _loadRollCallAttendance() async {
    final savedRollCalls =
        await RollCallStorage.getRollCalls(); // Lista de RollCall

    setState(() {
      for (var round in _rounds) {
        final matchingRollCall = savedRollCalls?.cast<RollCall>().firstWhere(
          (rc) =>
              rc.lesson.id == round.lesson.id && rc.student.id == student?.id,
          orElse: () => RollCall(
            id: -1, // id inválido só para placeholder
            lesson: round.lesson,
            student: student!,
            presence: false,
          ),
        );

        if (matchingRollCall != null && matchingRollCall.presence == true) {
          _attendanceStatus[round.roundNumber] = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usando a estrutura de Scaffold e Drawer que eu propus
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Chamadas'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: SyncIndicator()),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
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
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil em desenvolvimento')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
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
          const SizedBox(height: 10),
          FutureBuilder<Map<String, dynamic>>(
            future: ConsolidationService.getDailyConsolidation(
              student!.id!,
              DateTime.now(),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Text('Sem dados consolidados');
              }

              final data = snapshot.data!;
              final percentual = data['percentual'] as double;

              return Card(
                color: percentual >= 75
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hoje:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${percentual.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: percentual >= 75
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatChip(
                            'Presenças',
                            '${data['presencas']}/4',
                            Colors.green,
                          ),
                          _buildStatChip(
                            'Faltas',
                            '${data['faltas']}/4',
                            Colors.red,
                          ),
                          _buildStatChip(
                            'Atrasos',
                            '${data['atrasos']}/4',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Botão de Exportação CSV
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _exportCsvReport,
              icon: const Icon(Icons.download),
              label: const Text('Exportar Relatório CSV'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
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

                  if (!mounted) return;

                  final currentPosition = context
                      .read<DevicePositionProvider>()
                      .position;
                  if (currentPosition == null) {
                    print("Erro ao obter localização.");
                    return;
                  }

                  if (round.lesson.classRoom?.position == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sala sem coordenadas cadastradas'),
                      ),
                    );
                    return;
                  }

                  final targetLatitude =
                      round.lesson.classRoom!.position!.latitude;
                  final targetLongitude =
                      round.lesson.classRoom!.position!.longitude;

                  final distanceInMeters = Geolocator.distanceBetween(
                    currentPosition.latitude,
                    currentPosition.longitude,
                    targetLatitude,
                    targetLongitude,
                  );

                  print(
                    "Distância até o destino: ${distanceInMeters.toStringAsFixed(2)} m",
                  );

                  if (distanceInMeters <= 5) {
                    if (round.status == RollCallStatus.active) {
                      _recordPresence(round);
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '⚠️ Esta rodada não está ativa no momento',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Você está muito longe da sala!\n'
                          'Distância: ${(distanceInMeters / 1000).toStringAsFixed(2)} km\n'
                          'Você precisa estar a menos de 5 metros.',
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                child: const Text('Registrar'),
              ),
      ),
    );
  }

  Widget _buildProfessorView() {
    return FutureBuilder<List<RollCall>?>(
      future: RollCallStorage.getRollCalls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rollCalls = snapshot.data ?? [];

        if (rollCalls.isEmpty) {
          return const Center(child: Text('Nenhum registro de presença ainda'));
        }

        // Agrupar por aluno
        Map<String, List<RollCall>> byStudent = {};
        for (var rc in rollCalls) {
          final name = rc.student.name ?? 'Sem nome';
          byStudent.putIfAbsent(name, () => []).add(rc);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: byStudent.entries.map((entry) {
            final studentName = entry.key;
            final records = entry.value;
            final presencas = records.where((rc) => rc.presence).length;
            final total = records.length;
            final percentual = total > 0 ? (presencas / total * 100) : 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: percentual >= 75
                      ? Colors.green
                      : Colors.orange,
                  child: Text(
                    '${percentual.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(studentName),
                subtitle: Text('$presencas/$total presenças registradas'),
                children: records.asMap().entries.map((e) {
                  final idx = e.key;
                  final rc = e.value;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      rc.presence ? Icons.check : Icons.close,
                      color: rc.presence ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    title: Text('Rodada ${idx + 1}'),
                    subtitle: Text(rc.lesson.subject?.name ?? ''),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ClassRegistrationScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Gerenciar Cursos'),
              subtitle: const Text('Cadastrar e gerenciar cursos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CourseListScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Aqui podemos adicionar mais cards para outras funcionalidades administrativas
          Card(
            child: ListTile(
              leading: const Icon(Icons.class_),
              title: const Text('Gerenciar Aulas'),
              subtitle: const Text('Cadastrar e agendar novas aulas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LessonRegistrationScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Gerenciar Matérias'),
              subtitle: const Text('Cadastrar novas matérias no sistema'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubjectRegistrationScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Método para exportar relatório CSV
  Future<void> _exportCsvReport() async {
    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Exporta o CSV
      final result = await CsvExportService.exportCsv();

      // Fecha o loading
      if (mounted) Navigator.of(context).pop();

      // Mostra resultado
      if (result['success']) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('✅ Sucesso!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result['message']),
                  const SizedBox(height: 10),
                  const Text(
                    'Local:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    result['fileName'],
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'O arquivo foi salvo na pasta Downloads e pode ser acessado pelo gerenciador de arquivos do seu celular.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Fecha o loading em caso de erro
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
