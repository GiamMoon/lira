import 'package:flutter/foundation.dart';

/// Los tres tonos de dinámica de Lira.
///
/// Deliberadamente **no** existe un tipo "pregunta de comprensión": ninguna de
/// estas tiene respuesta correcta, y esa es la regla que hace que leer no se
/// sienta tarea.
enum ActivityKind {
  reflexionar('Reflexionar', '💭'),
  crear('Crear', '🎨'),
  queHarias('¿Qué harías tú?', '🔀');

  const ActivityKind(this.label, this.emoji);

  final String label;
  final String emoji;

  /// Nombre en la base de datos (`activities.kind`).
  String get storageName => switch (this) {
    ActivityKind.reflexionar => 'reflexionar',
    ActivityKind.crear => 'crear',
    ActivityKind.queHarias => 'que_harias',
  };

  static ActivityKind fromStorage(String value) => switch (value) {
    'crear' => ActivityKind.crear,
    'que_harias' => ActivityKind.queHarias,
    _ => ActivityKind.reflexionar,
  };
}

/// Una invitación creativa anclada al final de un capítulo.
@immutable
class Activity {
  const Activity({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.kind,
    required this.prompt,
    this.hint,
  });

  final String id;
  final String bookId;
  final String chapterId;
  final ActivityKind kind;

  /// La consigna. Corta, abierta y en segunda persona.
  final String prompt;

  /// Empujón opcional para quien se queda en blanco.
  final String? hint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Activity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
