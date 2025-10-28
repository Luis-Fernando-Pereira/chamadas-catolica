import 'user.dart';

// import 'lesson.dart';
// import 'student.dart';
// import 'class_model.dart'; // Nome sugerido para o arquivo da classe 'Class'
// import 'lesson_status.dart';

class Professor extends User {
  // Atributo específico da classe Professor
  String? actingField; // Área de atuação

  Professor({
    required int id,
    String? name,
    String? username,
    String? email,
    String? password,
    bool? isOnline,
    String? token,

    this.actingField,
  }) : super(
         // A palavra "super" passa os parâmetros para o construtor da classe pai (User)
         id: id,
         name: name,
         username: username,
         email: email,
         password: password,
         isOnline: isOnline,
         token: token,
       );

  // --- MÉTODOS ---

  /*
  /// Altera o status de uma aula (ex: de "Agendada" para "Em Andamento").
  Class? changeLessonStatus(Lesson lesson, LessonStatus newStatus) {
    // TODO: Implementar a lógica para alterar o status da aula.
    // lesson.lessonStatus = newStatus;
    // print('O status da aula ${lesson.id} foi alterado para ${newStatus.description}');
    // O diagrama indica que o método retorna um objeto 'Class',
    // então aqui retornaria a turma associada à aula.
    return lesson.assignedClass;
  }

  /// Adiciona um aluno a uma determinada turma.
  void addStudentToClass(Student student, Class assignedClass) {
    // TODO: Implementar a lógica para adicionar o aluno na lista de alunos da turma.
    // assignedClass.students.add(student);
    // print('O aluno ${student.name} foi adicionado à turma ${assignedClass.name}');
  }
  */
}
