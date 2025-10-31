// lib/model/class_room.dart

class ClassModel {
  final int? _id;

  String? name;

  String? latitude;
  String? longitude;

  ClassModel({required int id, this.name, this.latitude, this.longitude})
    : _id = id;

  int? get id => _id;
}
