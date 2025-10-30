import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/model/lesson.dart';
import 'package:appchamada/model/lesson_status.dart';
import 'package:appchamada/model/user.dart';

class Administrator extends User{
  
  Administrator({required super.id});

  Administrator.user({
    required super.id, 
    super.email,
    super.isOnline,
    super.name,
    super.password,
    super.token,
    super.username 
  });

  Lesson changeClassStatus(Lesson lesson, LessonStatus lessonStatus) {
    lesson.lessonStatus = lessonStatus;

    return lesson;
  }

  AssignedClass createClass(String className, int classId) => AssignedClass(id: classId, name: className);
  


}