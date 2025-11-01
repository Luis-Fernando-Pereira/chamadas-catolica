// lib/model/lesson.dart

// Imports necessários para as classes que compõem uma Lesson
import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/model/class_room.dart';
import 'package:appchamada/model/lesson_status.dart';
import 'package:appchamada/model/subject.dart';

class Lesson {
  final int? _id;
  DateTime? start;
  Duration? duration;
  Subject? subject;
  AssignedClass? assignedClass;
  LessonStatus? lessonStatus;
  ClassRoom? classRoom;

  Lesson({
    required int id,
    this.start,
    this.duration,
    this.subject,
    this.assignedClass,
    this.lessonStatus,
    this.classRoom,
  }) : _id = id;

  int? get id => _id;

  // === CONVERSORES JSON ===

  // Construtor factory para criar uma Lesson a partir de um mapa JSON
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      start: json['start'] != null ? DateTime.parse(json['start']) : null,
      duration: json['duration'] != null
          ? Duration(microseconds: json['duration'])
          : null,
      subject: json['subject'] != null
          ? Subject.fromJson(json['subject'])
          : null,
      assignedClass: json['assignedClass'] != null
          ? AssignedClass.fromJson(json['assignedClass'])
          : null,
      lessonStatus: json['lessonStatus'] != null
          ? LessonStatus.values.byName(json['lessonStatus'])
          : null,
      classRoom: json['classRoom'] != null
          ? ClassRoom.fromJson(json['classRoom'])
          : null,
    );
  }

  // Método para converter o objeto Lesson em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'start': start?.toIso8601String(),
      'duration': duration?.inMicroseconds,
      'subject': subject?.toJson(), // Chama o toJson() do Subject
      'assignedClass': assignedClass
          ?.toJson(), // Chama o toJson() do AssignedClass
      'lessonStatus':
          lessonStatus?.name, // Salva o nome do enum (ex: 'AGENDADO')
      'classRoom': classRoom?.toJson(), // Chama o toJson() do ClassRoom
    };
  }
}
