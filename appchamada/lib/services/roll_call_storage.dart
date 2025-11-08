// lib/services/roll_call_storage.dart
import 'dart:convert';
import 'package:appchamada/model/roll_call.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'remote_storage_service.dart';

class RollCallStorage {
  static const String _key = 'roll_calls_data';

  static Future<void> saveRollCall(RollCall rollCall) async {
    final prefs = await SharedPreferences.getInstance();

    final List<RollCall> rollCalls = (await getRollCalls()) ?? [];

    rollCalls.add(rollCall);

    final jsonString = jsonEncode(rollCalls.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);

    // Sincroniza com Firebase (não bloqueia se falhar)
    try {
      await RemoteStorageService.syncRollCall(rollCall);
      print('✅ Registro sincronizado com Firebase');
    } catch (e) {
      print('⚠️ Falha ao sincronizar com Firebase (salvo localmente): $e');
    }
  }

  static Future<List<RollCall>?> getRollCalls() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => RollCall.fromJson(e)).toList();
  }

  static Future<void> clearRollCalls() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
