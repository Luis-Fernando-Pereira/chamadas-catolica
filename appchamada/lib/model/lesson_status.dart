// lib/model/lesson_status.dart

enum LessonStatus {
  /// A aula foi agendada mas ainda não começou.
  AGENDADO,

  /// A aula está acontecendo neste momento.
  EM_ANDAMENTO,

  /// A aula já terminou.
  CONCLUIDO,

  /// A aula foi cancelada e não acontecerá.
  CANCELADO,
}
