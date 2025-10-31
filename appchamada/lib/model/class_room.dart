import 'package:geolocator/geolocator.dart';

class ClassRoom {
  final int? _id;

  String? name;

  Position? position;

  ClassRoom({required int id, this.name, this.position})
    : _id = id;

  int? get id => _id;
}
