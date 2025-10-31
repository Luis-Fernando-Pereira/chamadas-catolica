import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class DevicePositionProvider with ChangeNotifier, DiagnosticableTreeMixin {
  Position? _position;
  Position? get position => _position;

  Future<void> determinePosition() async {
    debugPrint('[DevicePositionProvider] Determinando posição...');

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('[DevicePositionProvider] Serviço ativo: $serviceEnabled');

      if (!serviceEnabled) {
        throw Exception('Serviço de localização desativado.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('[DevicePositionProvider] Permissão atual: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('[DevicePositionProvider] Nova permissão: $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão permanentemente negada.');
      }

      _position = await Geolocator.getCurrentPosition();
      debugPrint('[DevicePositionProvider] Nova posição: $_position');

      notifyListeners();
    } catch (e) {
      debugPrint('[DevicePositionProvider] Erro ao obter posição: $e');
      rethrow;
    }
  }
}
