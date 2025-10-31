// lib/model/class_model.dart

/// O nome 'ClassModel' é usado para evitar conflito com a palavra-chave 'class' do Dart.
class AssignedClass {
  final int? _id;

  String? name;

  // TODO: No futuro, esta classe provavelmente terá uma lista de alunos.
  // Ex: List<Student> students = [];

  AssignedClass({required int id, this.name}) : _id = id;

  int? get id => _id;

  factory AssignedClass.fromJson(Map<String, dynamic> json) => AssignedClass(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': _id,
        'name': name,
      };
}
