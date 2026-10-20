import 'package:flutter/foundation.dart';

import '../../../library/domain/entities/book.dart';
import '../../domain/entities/book_reaction.dart';

/// Estado de la pantalla de cierre.
@immutable
class ClosingState {
  const ClosingState({
    required this.book,
    this.reactions = const <BookReaction>{},
    this.stars,
    this.comment = '',
    this.isSaving = false,
  });

  final Book book;
  final Set<BookReaction> reactions;
  final int? stars;
  final String comment;
  final bool isSaving;

  static const Object _keep = Object();

  /// Si no eligió nada, el botón igual funciona: cerrar un libro en silencio
  /// es una respuesta válida. Esto sólo sirve para matizar el texto del botón.
  bool get hasAnything =>
      reactions.isNotEmpty || stars != null || comment.trim().isNotEmpty;

  ClosingState copyWith({
    Set<BookReaction>? reactions,
    Object? stars = _keep,
    String? comment,
    bool? isSaving,
  }) => ClosingState(
    book: book,
    reactions: reactions ?? this.reactions,
    stars: identical(stars, _keep) ? this.stars : stars as int?,
    comment: comment ?? this.comment,
    isSaving: isSaving ?? this.isSaving,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClosingState &&
          other.book == book &&
          setEquals(other.reactions, reactions) &&
          other.stars == stars &&
          other.comment == comment &&
          other.isSaving == isSaving;

  @override
  int get hashCode => Object.hash(
    book,
    Object.hashAllUnordered(reactions),
    stars,
    comment,
    isSaving,
  );
}
