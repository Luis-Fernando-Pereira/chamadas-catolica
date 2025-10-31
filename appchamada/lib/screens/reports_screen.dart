// lib/screens/reports_screen.dart

import 'package:flutter/material.dart';
import '../model/attendance_record.dart';
import '../model/user.dart';
import '../model/user_type.dart';

class ReportsScreen extends StatefulWidget {
  final User loggedInUser;

  const ReportsScreen({super.key, required this.loggedInUser});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<AttendanceRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  /// Carrega dados simulados para demonstração (N2 - em memória)
  void _loadMockData() {
    final now = DateTime.now();

    // Dados completos de todos os alunos
    final allRecords = [
      AttendanceRecord(
        studentId: 101,
        studentName: 'Miguel Aluno',
        date: now,
        round: 1,
        status: AttendanceStatus.presente,
        registrationTime: now.subtract(const Duration(hours: 2)),
        notes: 'Registrado no horário',
      ),
      AttendanceRecord(
        studentId: 101,
        studentName: 'Miguel Aluno',
        date: now,
        round: 2,
        status: AttendanceStatus.presente,
        registrationTime: now.subtract(const Duration(hours: 1)),
      ),
      AttendanceRecord(
        studentId: 101,
        studentName: 'Miguel Aluno',
        date: now,
        round: 3,
        status: AttendanceStatus.falta,
      ),
      AttendanceRecord(
        studentId: 102,
        studentName: 'Ana Silva',
        date: now,
        round: 1,
        status: AttendanceStatus.atraso,
        registrationTime: now.subtract(const Duration(hours: 2, minutes: 15)),
        notes: 'Chegou 15 minutos após o início',
      ),
      AttendanceRecord(
        studentId: 102,
        studentName: 'Ana Silva',
        date: now,
        round: 2,
        status: AttendanceStatus.falta,
      ),
      AttendanceRecord(
        studentId: 103,
        studentName: 'Carlos Santos',
        date: now,
        round: 1,
        status: AttendanceStatus.presente,
        registrationTime: now.subtract(const Duration(hours: 2)),
      ),
    ];

    // Filtrar baseado no tipo de usuário
    if (_isStudent()) {
      // ALUNO: Mostra apenas seus próprios registros
      _records = allRecords
          .where((record) => record.studentId == widget.loggedInUser.id)
          .toList();
    } else {
      // PROFESSOR/ADMIN: Mostra todos os registros
      _records = allRecords;
    }
  }

  /// Verifica se o usuário logado é um estudante
  bool _isStudent() {
    return widget.loggedInUser.userType == UserType.STUDENT;
  }

  /// Filtra registros pela data selecionada
  List<AttendanceRecord> _getFilteredRecords() {
    return _records.where((record) {
      return record.date.year == _selectedDate.year &&
          record.date.month == _selectedDate.month &&
          record.date.day == _selectedDate.day;
    }).toList();
  }

  /// Seleciona uma data usando DatePicker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Mostra o formato CSV em um diálogo
  void _showCsvFormat() {
    final filteredRecords = _getFilteredRecords();
    final csvContent = StringBuffer();
    csvContent.writeln(AttendanceRecord.csvHeader());
    for (var record in filteredRecords) {
      csvContent.writeln(record.toCsvRow());
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Formato CSV - Especificação'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Formato de exportação definido:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Colunas: ID, Nome, Data, Rodada, Status, Tempo_Registro, Notas',
              ),
              const SizedBox(height: 16),
              const Text(
                'Dados da data selecionada:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[200],
                child: SelectableText(
                  csvContent.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('FECHAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios de Presença')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de seleção de data
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtrar por Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Data selecionada: ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Alterar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card de ações
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exportação',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showCsvFormat,
                        icon: const Icon(Icons.file_download),
                        label: const Text('VER FORMATO CSV'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Formato CSV definido com 7 colunas: ID, Nome, Data, Rodada, Status, Tempo_Registro, Notas',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card de estatísticas
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estatísticas do Dia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Total',
                          filteredRecords.length.toString(),
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Presentes',
                          filteredRecords
                              .where(
                                (r) => r.status == AttendanceStatus.presente,
                              )
                              .length
                              .toString(),
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Faltas',
                          filteredRecords
                              .where((r) => r.status == AttendanceStatus.falta)
                              .length
                              .toString(),
                          Colors.red,
                        ),
                        _buildStatCard(
                          'Atrasos',
                          filteredRecords
                              .where((r) => r.status == AttendanceStatus.atraso)
                              .length
                              .toString(),
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de registros
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Histórico de Registros',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    filteredRecords.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'Nenhum registro encontrado para esta data.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredRecords.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final record = filteredRecords[index];
                              return _buildRecordTile(record);
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um card de estatística
  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  /// Constrói um tile de registro
  Widget _buildRecordTile(AttendanceRecord record) {
    Color statusColor;
    IconData statusIcon;

    switch (record.status) {
      case AttendanceStatus.presente:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case AttendanceStatus.falta:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case AttendanceStatus.atraso:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor,
        child: Icon(statusIcon, color: Colors.white),
      ),
      title: Text(
        record.studentName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rodada ${record.round} - ${record.status.description}'),
          if (record.registrationTime != null)
            Text(
              'Registrado às ${record.registrationTime!.hour.toString().padLeft(2, '0')}:${record.registrationTime!.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          if (record.notes != null && record.notes!.isNotEmpty)
            Text(
              record.notes!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      ),
      trailing: Text(
        'ID: ${record.studentId}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
