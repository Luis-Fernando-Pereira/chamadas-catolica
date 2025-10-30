import 'class_model.dart';
import 'lesson_status.dart';
//import 'class_room.dart';
//import 'subject.dart';

class Lesson {
  final int? _id;
  DateTime? start;
  Duration?
  duration; // A classe Duration é ideal para representar um período de tempo, como minutos.

  Subject? subject;
  ClassModel?
  assignedClass; // Usamos 'assignedClass' para evitar conflito com a palavra-chave 'class'.
  LessonStatus? lessonStatus;
  ClassRoom? classRoom;

  // Construtor da classe
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
}
