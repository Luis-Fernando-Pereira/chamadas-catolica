import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/roll_call.dart';

class RemoteStorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'roll_calls';

  /// Sincroniza um registro de presença com o Firebase
  static Future<bool> syncRollCall(RollCall rollCall) async {
    try {
      // Converte o RollCall para JSON
      final data = rollCall.toJson();

      // Adiciona timestamp de sincronização
      data['syncedAt'] = FieldValue.serverTimestamp();

      // Usa o ID do RollCall como ID do documento
      await _firestore
          .collection(_collectionName)
          .doc(rollCall.id.toString())
          .set(data, SetOptions(merge: true));

      print('✅ RollCall ${rollCall.id} sincronizado com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao sincronizar RollCall: $e');
      return false;
    }
  }

  /// Sincroniza múltiplos registros de presença
  static Future<Map<String, dynamic>> syncMultipleRollCalls(
    List<RollCall> rollCalls,
  ) async {
    int successCount = 0;
    int failCount = 0;

    for (var rollCall in rollCalls) {
      final success = await syncRollCall(rollCall);
      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    return {
      'success': successCount,
      'failed': failCount,
      'total': rollCalls.length,
    };
  }

  /// Busca todos os registros de presença de um aluno específico
  static Future<List<RollCall>> getRollCallsByStudent(int studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('student.id', isEqualTo: studentId)
          .orderBy('recordedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RollCall.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar registros do aluno: $e');
      return [];
    }
  }

  /// Busca registros de presença por data
  static Future<List<RollCall>> getRollCallsByDate(DateTime date) async {
    try {
      // Início e fim do dia
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where(
            'recordedAt',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where('recordedAt', isLessThanOrEqualTo: endOfDay.toIso8601String())
          .get();

      return querySnapshot.docs
          .map((doc) => RollCall.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar registros por data: $e');
      return [];
    }
  }

  /// Verifica se há conexão com o Firebase
  static Future<bool> checkConnection() async {
    try {
      // Tenta fazer uma leitura simples para verificar conexão
      await _firestore
          .collection(_collectionName)
          .limit(1)
          .get(const GetOptions(source: Source.server));
      return true;
    } catch (e) {
      print('❌ Sem conexão com Firebase: $e');
      return false;
    }
  }

  /// Deleta um registro de presença do Firebase
  static Future<bool> deleteRollCall(int rollCallId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(rollCallId.toString())
          .delete();

      print('✅ RollCall $rollCallId deletado com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao deletar RollCall: $e');
      return false;
    }
  }

  /// Limpa todos os registros de presença (usar com cuidado!)
  static Future<bool> clearAllRollCalls() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ Todos os registros foram limpos');
      return true;
    } catch (e) {
      print('❌ Erro ao limpar registros: $e');
      return false;
    }
  }

  /// Obtém estatísticas de sincronização
  static Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      int totalRecords = querySnapshot.docs.length;
      int presences = 0;
      int absences = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['presence'] == true) {
          presences++;
        } else {
          absences++;
        }
      }

      return {
        'totalRecords': totalRecords,
        'presences': presences,
        'absences': absences,
      };
    } catch (e) {
      print('❌ Erro ao obter estatísticas: $e');
      return {'totalRecords': 0, 'presences': 0, 'absences': 0};
    }
  }
}
