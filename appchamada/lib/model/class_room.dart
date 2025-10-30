// lib/model/class_room.dart

class ClassRoom {
  final int? _id;

  String? name;

  String? latitude;
  String? longitude;

  ClassRoom({required int id, this.name, this.latitude, this.longitude})
    : _id = id;

  int? get id => _id;
}
