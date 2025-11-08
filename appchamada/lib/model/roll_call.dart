import 'package:appchamada/model/lesson.dart';
import 'package:appchamada/model/student.dart';

class RollCall {
  int id;
  bool presence;
  Student student;
  Lesson lesson;
  DateTime? recordedAt; // Timestamp do registro de presença

  RollCall({
    required this.id,
    this.presence = false,
    required this.student,
    required this.lesson,
    this.recordedAt,
  });

  // ---------------- JSON ----------------
  factory RollCall.fromJson(Map<String, dynamic> json) => RollCall(
    id: json['id'],
    presence: json['presence'] ?? false,
    student: Student.fromJson(json['student']),
    lesson: Lesson.fromJson(json['lesson']),
    recordedAt: json['recordedAt'] != null
        ? DateTime.parse(json['recordedAt'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'presence': presence,
    'student': student.toJson(),
    'lesson': lesson.toJson(),
    'recordedAt': recordedAt?.toIso8601String(),
  };
}
