import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/roll_call.dart';
import 'roll_call_storage.dart';

class CsvExportService {
  /// Gera o conteúdo CSV a partir dos registros de presença
  static String generateCsvContent(List<RollCall> rollCalls) {
    // Cabeçalho do CSV conforme especificação
    final buffer = StringBuffer();
    buffer.writeln('ID,Nome,Data,Rodada,Status,TempoRegistro,Notas');

    // Agrupar por aluno e data para determinar o número da rodada
    for (var rc in rollCalls) {
      final id = rc.student.id ?? 0;
      final nome = rc.student.name ?? 'Sem nome';

      // Data da aula no formato YYYY-MM-DD
      final data = rc.lesson.start != null
          ? rc.lesson.start!.toIso8601String().substring(0, 10)
          : DateTime.now().toIso8601String().substring(0, 10);

      // Determinar número da rodada (simplificado - pode ser melhorado)
      final rodada = _determineRoundNumber(rc, rollCalls);

      // Status: P (Presente), F (Falta), A (Atraso)
      final status = rc.presence ? 'P' : 'F';

      // Tempo de registro no formato HH:MM:SS
      final tempoRegistro = rc.recordedAt != null
          ? rc.recordedAt!.toIso8601String().substring(11, 19)
          : '';

      // Notas (opcional)
      final notas = '';

      buffer.writeln('$id,$nome,$data,$rodada,$status,$tempoRegistro,$notas');
    }

    return buffer.toString();
  }

  /// Determina o número da rodada baseado na sequência de registros
  static int _determineRoundNumber(RollCall current, List<RollCall> allCalls) {
    // Filtra registros do mesmo aluno e mesma data
    final sameDay = allCalls.where((rc) {
      if (rc.lesson.start == null || current.lesson.start == null) return false;

      final rcDate = rc.lesson.start!;
      final currentDate = current.lesson.start!;

      return rc.student.id == current.student.id &&
          rcDate.year == currentDate.year &&
          rcDate.month == currentDate.month &&
          rcDate.day == currentDate.day;
    }).toList();

    // Ordena por horário de início da aula
    sameDay.sort((a, b) => a.lesson.start!.compareTo(b.lesson.start!));

    // Encontra o índice do registro atual
    final index = sameDay.indexWhere((rc) => rc.id == current.id);

    return index >= 0 ? index + 1 : 1;
  }

  /// Solicita permissões de armazenamento
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Para Android 13+ (API 33+), não precisa de permissão para Downloads
      if (await Permission.storage.isGranted) {
        return true;
      }

      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // Tenta permissão de gerenciamento de arquivos externos
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    }

    return true; // iOS não precisa de permissão especial
  }

  /// Salva o CSV no diretório de Downloads
  static Future<String?> exportToDownloads() async {
    try {
      // Solicita permissões
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Permissão de armazenamento negada');
      }

      // Carrega os registros de presença
      final rollCalls = await RollCallStorage.getRollCalls() ?? [];

      if (rollCalls.isEmpty) {
        throw Exception('Nenhum registro de presença para exportar');
      }

      // Gera o conteúdo CSV
      final csvContent = generateCsvContent(rollCalls);

      // Obtém o diretório de Downloads
      Directory? directory;

      if (Platform.isAndroid) {
        // Para Android, usa o diretório de Downloads público
        directory = Directory('/storage/emulated/0/Download');

        // Se não existir, tenta criar ou usar diretório alternativo
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        // Para iOS, usa o diretório de documentos
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Não foi possível acessar o diretório de Downloads');
      }

      // Nome do arquivo com timestamp
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .substring(0, 19);
      final fileName = 'chamadas_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      // Cria e escreve o arquivo
      final file = File(filePath);
      await file.writeAsString(csvContent);

      return filePath;
    } catch (e) {
      print('Erro ao exportar CSV: $e');
      return null;
    }
  }

  /// Exporta CSV e retorna informações sobre o arquivo
  static Future<Map<String, dynamic>> exportCsv() async {
    try {
      final filePath = await exportToDownloads();

      if (filePath == null) {
        return {'success': false, 'message': 'Falha ao exportar CSV'};
      }

      final file = File(filePath);
      final fileSize = await file.length();

      return {
        'success': true,
        'message': 'CSV exportado com sucesso!',
        'filePath': filePath,
        'fileName': filePath.split('/').last,
        'fileSize': fileSize,
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro: $e'};
    }
  }
}
