import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../library/data/library_providers.dart';
import '../../../library/domain/book_not_found_exception.dart';
import '../../data/closing_providers.dart';
import '../../domain/entities/book_feedback.dart';
import '../../domain/entities/book_reaction.dart';
import 'closing_state.dart';

part 'closing_view_model.g.dart';

/// ViewModel del cierre de una obra.
///
/// Nada aquí valida ni exige: se puede guardar sin reacción, sin estrellas y
/// sin comentario. El único trabajo real es recordar lo que ya dijo, por si
/// vuelve a abrir la pantalla.
@riverpod
class ClosingViewModel extends _$ClosingViewModel {
  @override
  Future<ClosingState> build(String bookId) async {
    final book = await ref.watch(bookRepositoryProvider).fetchBook(bookId);
    if (book == null) throw BookNotFoundException(bookId);

    final existing = await ref
        .watch(bookFeedbackRepositoryProvider)
        .fetchFor(bookId);

    return ClosingState(
      book: book,
      reactions: existing?.reactions ?? const <BookReaction>{},
      stars: existing?.stars,
      comment: existing?.comment ?? '',
    );
  }

  /// Multi-selección: un libro puede molestar y gustar a la vez.
  void toggleReaction(BookReaction reaction) {
    _mutate((state) {
      final next = <BookReaction>{...state.reactions};
      if (!next.remove(reaction)) next.add(reaction);
      return state.copyWith(reactions: next);
    });
  }

  /// Tocar la estrella que ya estaba puesta quita la calificación: cambiar de
  /// opinión —o no querer calificar— tiene que ser posible.
  void setStars(int stars) {
    _mutate(
      (state) => state.copyWith(stars: state.stars == stars ? null : stars),
    );
  }

  void setComment(String comment) =>
      _mutate((state) => state.copyWith(comment: comment));

  Future<void> submit() async {
    final current = state.value;
    if (current == null || current.isSaving) return;

    _mutate((state) => state.copyWith(isSaving: true));

    final comment = current.comment.trim();
    await ref
        .read(bookFeedbackRepositoryProvider)
        .save(
          BookFeedback(
            bookId: current.book.id,
            reactions: current.reactions,
            stars: current.stars,
            comment: comment.isEmpty ? null : comment,
            createdAt: DateTime.now(),
          ),
        );

    _mutate((state) => state.copyWith(isSaving: false));
  }

  void _mutate(ClosingState Function(ClosingState state) transform) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData<ClosingState>(transform(current));
  }
}
