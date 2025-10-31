// lib/model/subject.dart

class Subject {
  final int? _id;

  String? name;

  Subject({required int id, this.name}) : _id = id;

  int? get id => _id;

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': _id,
        'name': name,
      };
}
