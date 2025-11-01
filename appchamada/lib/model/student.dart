// lib/model/student.dart
import 'package:appchamada/model/assigned_class.dart';
import 'package:appchamada/model/course.dart';
import 'package:appchamada/model/user_type.dart';

import 'user.dart';

class Student extends User {
  Course? course;
  AssignedClass? assignedClass;
  int? semester;

  Student({
    required int id,
    String? name,
    String? username,
    String? email,
    String? password,
    bool? isOnline,
    String? token,
    this.course,
    this.assignedClass,
    this.semester,
  }) : super(
         id: id,
         name: name,
         username: username,
         email: email,
         password: password,
         isOnline: isOnline,
         token: token,
         userType: UserType.STUDENT,
       );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'password': password,
    'isOnline': isOnline,
    'token': token,
    'course': course != null ? {'id': course!.id, 'name': course!.name} : null,
    'assignedClass': assignedClass != null
        ? {'id': assignedClass!.id, 'name': assignedClass!.name}
        : null,
    'semester': semester,
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'],
    name: json['name'],
    username: json['username'],
    email: json['email'],
    password: json['password'],
    isOnline: json['isOnline'],
    token: json['token'],
    course: json['course'] != null
        ? Course(id: json['course']['id'], name: json['course']['name'])
        : null,
    assignedClass: json['assignedClass'] != null
        ? AssignedClass(
            id: json['assignedClass']['id'],
            name: json['assignedClass']['name'],
          )
        : null,
    semester: json['semester'],
  );
}
