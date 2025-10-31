// lib/model/student.dart

import 'user.dart';
import 'course.dart';
import 'class_model.dart';
import 'user_type.dart';

// import 'roll_call.dart';

class Student extends User {
  Course? course;
  ClassModel? assignedClass;
  int? semester;

  Student({
    required int id,
    String? name,
    String? username,
    String? email,
    String? password,
    bool? isOnline,
    String? token,
    UserType? userType,

    // O UserType de um Student será sempre UserType.STUDENT
    // Poderíamos fixar isso aqui, se quiséssemos.
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
         userType: userType,
       );

  /*
  /// Comportamento responsável por responder a uma chamada, aplicando as devidas regras de negócio.
  /// Retorna 'true' se a presença foi confirmada com sucesso, e 'false' caso contrário.
  bool answerRollCall(RollCall rollCall) {
    // TODO: Implementar a lógica de negócio para responder à chamada.
    // Exemplo de lógica:
    // 1. Verificar se a chamada (rollCall) está aberta.
    // 2. Verificar a geolocalização do aluno.
    // 3. Se tudo estiver OK, registrar a presença.
    
    print('O aluno ${name ?? 'desconhecido'} respondeu à chamada ${rollCall.id}');
    
    
    return true; 
  }
  */
}
