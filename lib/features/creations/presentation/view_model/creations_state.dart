import 'package:flutter/foundation.dart';

import '../../../reader/domain/entities/activity.dart';
import '../../../reader/domain/entities/activity_response.dart';

/// Una cosa que el estudiante escribió, con el contexto de dónde salió.
@immutable
class CreationEntry {
  const CreationEntry({
    required this.bookTitle,
    required this.activity,
    required this.response,
  });

  final String bookTitle;
  final Activity activity;
  final ActivityResponse response;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreationEntry &&
          other.bookTitle == bookTitle &&
          other.activity == activity &&
          other.response == response;

  @override
  int get hashCode => Object.hash(bookTitle, activity, response);
}

/// Lo que el estudiante lleva hecho en Lira.
///
/// Todos los números salen de lo que hay guardado de verdad. Nada de rachas
/// inventadas ni metas que no eligió: si no ha leído, dice que no ha leído.
@immutable
class CreationsState {
  const CreationsState({
    required this.entries,
    required this.booksFinished,
    required this.booksStarted,
    required this.chaptersRead,
  });

  final List<CreationEntry> entries;
  final int booksFinished;
  final int booksStarted;
  final int chaptersRead;

  bool get isEmpty => entries.isEmpty;

  /// Minutos aproximados, a 200 palabras por minuto de lectura.
  int get minutesRead => chaptersRead * 4;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreationsState &&
          listEquals(other.entries, entries) &&
          other.booksFinished == booksFinished &&
          other.booksStarted == booksStarted &&
          other.chaptersRead == chaptersRead;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(entries),
    booksFinished,
    booksStarted,
    chaptersRead,
  );
}
