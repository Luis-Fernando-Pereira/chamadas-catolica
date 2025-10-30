// lib/model/class_model.dart

/// O nome 'ClassModel' é usado para evitar conflito com a palavra-chave 'class' do Dart.
class ClassModel {
  final int? _id;

  String? name;

  // TODO: No futuro, esta classe provavelmente terá uma lista de alunos.
  // Ex: List<Student> students = [];

  ClassModel({required int id, this.name}) : _id = id;

  int? get id => _id;
}
