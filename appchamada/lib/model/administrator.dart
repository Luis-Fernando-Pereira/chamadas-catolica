// lib/model/administrator.dart

import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/model/lesson.dart';
import 'package:appchamada/model/lesson_status.dart';
import 'package:appchamada/model/user.dart';
import 'package:appchamada/model/user_type.dart'; // <-- IMPORT ADICIONADO

class Administrator extends User {
  Administrator({required super.id});

  // ESTE CONSTRUTOR FOI CORRIGIDO
  Administrator.user({
    required super.id,
    super.email,
    super.isOnline,
    super.name,
    super.password,
    super.token,
    super.username,
    super.userType, // <-- PARÂMETRO ADICIONADO AQUI
  });

  Lesson changeClassStatus(Lesson lesson, LessonStatus lessonStatus) {
    lesson.lessonStatus = lessonStatus;
    return lesson;
  }

  AssignedClass createClass(String className, int classId) =>
      AssignedClass(id: classId, name: className);
}
