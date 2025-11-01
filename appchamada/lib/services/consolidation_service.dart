import 'roll_call_storage.dart';

class ConsolidationService {
  static Future<Map<String, dynamic>> getDailyConsolidation(
    int studentId,
    DateTime date,
  ) async {
    final allRollCalls = await RollCallStorage.getRollCalls() ?? [];

    final dailyRecords = allRollCalls.where((rc) {
      final rcDate = rc.lesson.start;
      return rc.student.id == studentId &&
          rcDate != null &&
          rcDate.year == date.year &&
          rcDate.month == date.month &&
          rcDate.day == date.day;
    }).toList();

    int presencas = dailyRecords.where((rc) => rc.presence).length;
    int faltas = dailyRecords.where((rc) => !rc.presence).length;
    int atrasos = 0;
    return {
      'presencas': presencas,
      'faltas': faltas,
      'atrasos': atrasos,
      'total': dailyRecords.length,
      'percentual': dailyRecords.isNotEmpty
          ? (presencas / dailyRecords.length * 100)
          : 0.0,
    };
  }
}
