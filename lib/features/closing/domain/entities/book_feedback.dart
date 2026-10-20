import 'package:flutter/foundation.dart';

import 'book_reaction.dart';

/// Lo que el estudiante dejó al terminar una obra.
///
/// **Todo es opcional**: se puede cerrar un libro sin decir nada, sólo con
/// estrellas, o sólo con una reacción. Por eso [stars] y [comment] son
/// nullables y [reactions] puede venir vacío — no son campos "sin llenar",
/// son decisiones legítimas.
@immutable
class BookFeedback {
  const BookFeedback({
    required this.bookId,
    required this.createdAt,
    this.reactions = const <BookReaction>{},
    this.stars,
    this.comment,
  });

  final String bookId;
  final Set<BookReaction> reactions;

  /// 1 a 5, o `null` si prefirió no calificar.
  final int? stars;

  final String? comment;
  final DateTime createdAt;

  bool get isEmpty =>
      reactions.isEmpty && stars == null && (comment?.isEmpty ?? true);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookFeedback &&
          other.bookId == bookId &&
          setEquals(other.reactions, reactions) &&
          other.stars == stars &&
          other.comment == comment &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    bookId,
    Object.hashAllUnordered(reactions),
    stars,
    comment,
    createdAt,
  );
}
