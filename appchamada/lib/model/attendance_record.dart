// lib/model/attendance_record.dart

/// Modelo para registro de presença individual
/// Contém as 7 colunas mínimas definidas na documentação:
/// ID, Nome, Data, Rodada, Status, Tempo de Registro, Notas
class AttendanceRecord {
  final int studentId;
  final String studentName;
  final DateTime date;
  final int round; // 1, 2, 3 ou 4
  final AttendanceStatus status; // P, F ou A
  final DateTime? registrationTime; // Quando registrou presença
  final String? notes; // Observações adicionais

  AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.round,
    required this.status,
    this.registrationTime,
    this.notes,
  });

  /// Converte o registro para formato CSV
  String toCsvRow() {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final timeStr = registrationTime != null
        ? '${registrationTime!.hour.toString().padLeft(2, '0')}:${registrationTime!.minute.toString().padLeft(2, '0')}:${registrationTime!.second.toString().padLeft(2, '0')}'
        : '';
    final notesStr = notes ?? '';

    return '$studentId,$studentName,$dateStr,$round,${status.code},$timeStr,$notesStr';
  }

  /// Retorna o cabeçalho CSV
  static String csvHeader() {
    return 'ID,Nome,Data,Rodada,Status,Tempo_Registro,Notas';
  }
}

/// Enum para status de presença
enum AttendanceStatus {
  presente('P', 'Presente'),
  falta('F', 'Falta'),
  atraso('A', 'Atraso');

  const AttendanceStatus(this.code, this.description);

  final String code;
  final String description;
}
