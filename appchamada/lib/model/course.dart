class Course {
  final int? _id;

  String? name;

  Course({required int id, this.name}) : _id = id;

  int? get id => _id;

  Map<String, dynamic> toJson() => {'id': _id, 'name': name};

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(id: json['id'] as int, name: json['name'] as String?);
  }
}
