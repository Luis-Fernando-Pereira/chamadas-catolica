class Course {
  final int? _id;

  String? name;

  Course({required int id, this.name}) : _id = id;

  int? get id => _id;
}
