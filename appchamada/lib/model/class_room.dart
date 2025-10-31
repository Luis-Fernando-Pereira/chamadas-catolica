import 'package:geolocator/geolocator.dart';

class ClassRoom {
  final int? _id;
  String? name;

  Position? position;

  ClassRoom({required int id, this.name, this.position})
    : _id = id;

  int? get id => _id;

  factory ClassRoom.fromJson(Map<String, dynamic> json) => ClassRoom(
        id: json['id'],
        name: json['name'],
        position: json['position'] != null
            ? Position(
                latitude: json['position']['latitude'],
                longitude: json['position']['longitude'],
                accuracy: json['position']['accuracy']?.toDouble() ?? 0,
                altitude: json['position']['altitude']?.toDouble() ?? 0,
                altitudeAccuracy: json['position']['altitudeAccuracy']?.toDouble() ?? 0,
                heading: json['position']['heading']?.toDouble() ?? 0,
                headingAccuracy: json['position']['headingAccuracy']?.toDouble() ?? 0,
                speed: json['position']['speed']?.toDouble() ?? 0,
                speedAccuracy: json['position']['speedAccuracy']?.toDouble() ?? 0,
                timestamp: json['position']['timestamp'] != null
                    ? DateTime.parse(json['position']['timestamp'])
                    : DateTime.now(),
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': _id,
        'name': name,
        'position': position != null
            ? {
                'latitude': position!.latitude,
                'longitude': position!.longitude,
                'accuracy': position!.accuracy,
                'altitude': position!.altitude,
                'altitudeAccuracy': position!.altitudeAccuracy,
                'heading': position!.heading,
                'headingAccuracy': position!.headingAccuracy,
                'speed': position!.speed,
                'speedAccuracy': position!.speedAccuracy,
                'timestamp': position!.timestamp.toIso8601String(),
              }
            : null,
      };
}
