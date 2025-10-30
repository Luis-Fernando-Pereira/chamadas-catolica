// lib/model/subject.dart

class Subject {
  final int? _id;

  String? name;

  Subject({required int id, this.name}) : _id = id;

  int? get id => _id;
}
