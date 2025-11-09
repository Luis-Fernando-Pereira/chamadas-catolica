// lib/screens/class_room_form_screen.dart
import 'package:appchamada/model/class_room.dart';
import 'package:appchamada/provider/device_position_provider.dart';
import 'package:appchamada/services/class_room_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ClassRoomFormScreen extends StatefulWidget {
  final ClassRoom? classRoom;
  const ClassRoomFormScreen({super.key, this.classRoom});

  @override
  State<ClassRoomFormScreen> createState() => _ClassRoomFormScreenState();
}

class _ClassRoomFormScreenState extends State<ClassRoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  bool _isLoading = false;
  bool _isCapturingLocation = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    if (widget.classRoom != null) {
      _nameController.text = widget.classRoom!.name ?? '';
      if (widget.classRoom!.position != null) {
        _latitudeController.text = widget.classRoom!.position!.latitude
            .toString();
        _longitudeController.text = widget.classRoom!.position!.longitude
            .toString();
        _currentPosition = widget.classRoom!.position;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _captureCurrentLocation() async {
    setState(() => _isCapturingLocation = true);

    try {
      var status = await Permission.location.status;
      if (status.isDenied) {
        status = await Permission.location.request();
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        await Geolocator.openLocationSettings();
        return;
      }

      final positionProvider = context.read<DevicePositionProvider>();
      await positionProvider.determinePosition();
      final position = positionProvider.position;

      if (position != null && mounted) {
        setState(() {
          _currentPosition = position;
          _latitudeController.text = position.latitude.toString();
          _longitudeController.text = position.longitude.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Localização capturada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturingLocation = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      Position? position;

      if (_latitudeController.text.isNotEmpty &&
          _longitudeController.text.isNotEmpty) {
        final latitude = double.tryParse(_latitudeController.text);
        final longitude = double.tryParse(_longitudeController.text);

        if (latitude != null && longitude != null) {
          position = Position(
            latitude: latitude,
            longitude: longitude,
            timestamp: DateTime.now(),
            accuracy: _currentPosition?.accuracy ?? 0,
            altitude: _currentPosition?.altitude ?? 0,
            altitudeAccuracy: _currentPosition?.altitudeAccuracy ?? 0,
            heading: _currentPosition?.heading ?? 0,
            headingAccuracy: _currentPosition?.headingAccuracy ?? 0,
            speed: _currentPosition?.speed ?? 0,
            speedAccuracy: _currentPosition?.speedAccuracy ?? 0,
          );
        }
      }

      if (widget.classRoom != null) {
        final updated = ClassRoom(
          id: widget.classRoom!.id!,
          name: name,
          position: position,
        );
        await ClassRoomStorage.updateClassRoom(updated);
      } else {
        final id = DateTime.now().millisecondsSinceEpoch % 1000000000;
        final newClassRoom = ClassRoom(id: id, name: name, position: position);
        await ClassRoomStorage.saveClassRoom(newClassRoom);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.classRoom != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Sala' : 'Nova Sala')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Sala',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Localização GPS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _isCapturingLocation
                        ? null
                        : _captureCurrentLocation,
                    icon: _isCapturingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: const Text('Capturar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'SALVAR' : 'CRIAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
