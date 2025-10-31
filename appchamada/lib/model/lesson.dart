import 'package:appchamada/model/class_room.dart';
import 'package:appchamada/model/subject.dart';

import 'assigned_class.dart';
import 'lesson_status.dart';
//import 'class_room.dart';
//import 'subject.dart';

class Lesson {
  final int? _id;
  DateTime? start;
  Duration? duration; // A classe Duration é ideal para representar um período de tempo, como minutos.

  Subject? subject;
  AssignedClass? assignedClass; // Usamos 'assignedClass' para evitar conflito com a palavra-chave 'class'.
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

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'],
        start: json['start'] != null ? DateTime.parse(json['start']) : null,
        duration: json['duration'] != null
            ? Duration(minutes: json['duration'])
            : null,
        subject: json['subject'] != null ? Subject.fromJson(json['subject']) : null,
        assignedClass: json['assignedClass'] != null
            ? AssignedClass.fromJson(json['assignedClass'])
            : null,
        lessonStatus: json['lessonStatus'] != null
            ? LessonStatus.values.firstWhere(
                (e) => e.toString() == 'LessonStatus.${json['lessonStatus']}',
              )
            : null,
        classRoom: json['classRoom'] != null ? ClassRoom.fromJson(json['classRoom']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': _id,
        'start': start?.toIso8601String(),
        'duration': duration?.inMinutes,
        'subject': subject?.toJson(),
        'assignedClass': assignedClass?.toJson(),
        'lessonStatus': lessonStatus?.toString().split('.').last,
        'classRoom': classRoom?.toJson(),
      };
}
