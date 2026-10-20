import 'package:flutter/foundation.dart';

/// En qué punto de su relación con un libro está el estudiante.
///
/// `abandoned` no es un fracaso: es un estado de primera clase. Lira nunca
/// obliga a terminar una obra, así que dejarla debe poder registrarse sin
/// castigo y sin perder el avance.
enum ReadingStatus { reading, finished, abandoned }

@immutable
class ReadingProgress {
  const ReadingProgress({
    required this.bookId,
    required this.chaptersRead,
    required this.chapterCount,
    required this.status,
    required this.updatedAt,
  });

  /// Progreso recién creado al abrir una obra por primera vez.
  factory ReadingProgress.started({
    required String bookId,
    required int chapterCount,
    required DateTime now,
  }) => ReadingProgress(
    bookId: bookId,
    chaptersRead: 0,
    chapterCount: chapterCount,
    status: ReadingStatus.reading,
    updatedAt: now,
  );

  final String bookId;
  final int chaptersRead;
  final int chapterCount;
  final ReadingStatus status;
  final DateTime updatedAt;

  /// 0.0 → 1.0. Se calcula por capítulos leídos, no por scroll: es la unidad
  /// que el estudiante entiende ("voy por el 3 de 8").
  double get fraction =>
      chapterCount <= 0 ? 0 : (chaptersRead / chapterCount).clamp(0.0, 1.0);

  /// El progreso medido contra el total **actual** de la obra.
  ///
  /// [chapterCount] es el que había cuando se guardó el avance, y el catálogo
  /// cambia: un libro que tenía 1 capítulo y ahora tiene 96 marcaría 100% para
  /// siempre. Donde haya un `Book` a mano, se usa este.
  double fractionOf(int total) =>
      total <= 0 ? 0 : (chaptersRead / total).clamp(0.0, 1.0);

  int get percent => (fraction * 100).round();

  bool get isActive => status == ReadingStatus.reading;
  bool get hasStarted => chaptersRead > 0;

  ReadingProgress copyWith({
    int? chaptersRead,
    ReadingStatus? status,
    DateTime? updatedAt,
  }) => ReadingProgress(
    bookId: bookId,
    chaptersRead: chaptersRead ?? this.chaptersRead,
    chapterCount: chapterCount,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgress &&
          other.bookId == bookId &&
          other.chaptersRead == chaptersRead &&
          other.chapterCount == chapterCount &&
          other.status == status &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(bookId, chaptersRead, chapterCount, status, updatedAt);
}
