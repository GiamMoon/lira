import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/book_feedback.dart';
import '../../domain/entities/book_reaction.dart';
import '../../domain/repositories/book_feedback_repository.dart';

/// Reacción, estrellas y comentario, en la nube.
///
/// Van en dos tablas porque son dos cosas distintas: `book_ratings` guarda una
/// fila por libro (estrellas y comentario, los dos opcionales) y
/// `book_reactions` una fila por cada emoji elegido, porque se pueden marcar
/// varios.
class SupabaseBookFeedbackRepository implements BookFeedbackRepository {
  const SupabaseBookFeedbackRepository(this._client);

  final SupabaseClient _client;

  String get _usuario => _client.auth.currentUser!.id;

  @override
  Future<BookFeedback?> fetchFor(String bookId) async {
    final calificacion = await _client
        .from('book_ratings')
        .select('stars, comment, created_at')
        .eq('user_id', _usuario)
        .eq('book_id', bookId)
        .maybeSingle();

    final reacciones = await _client
        .from('book_reactions')
        .select('reaction')
        .eq('user_id', _usuario)
        .eq('book_id', bookId);

    if (calificacion == null && reacciones.isEmpty) return null;

    return BookFeedback(
      bookId: bookId,
      reactions: reacciones
          .map((fila) => BookReaction.fromStorage(fila['reaction'] as String))
          .nonNulls
          .toSet(),
      stars: (calificacion?['stars'] as num?)?.toInt(),
      comment: calificacion?['comment'] as String?,
      createdAt:
          DateTime.tryParse((calificacion?['created_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  @override
  Future<void> save(BookFeedback feedback) async {
    final tieneCalificacion =
        feedback.stars != null || (feedback.comment?.isNotEmpty ?? false);

    if (tieneCalificacion) {
      await _client.from('book_ratings').upsert({
        'user_id': _usuario,
        'book_id': feedback.bookId,
        'stars': feedback.stars,
        'comment': feedback.comment,
        'created_at': feedback.createdAt.toIso8601String(),
      }, onConflict: 'user_id,book_id');
    } else {
      // Quitó las estrellas y borró el comentario: la fila deja de existir.
      await _client
          .from('book_ratings')
          .delete()
          .eq('user_id', _usuario)
          .eq('book_id', feedback.bookId);
    }

    // Las reacciones se reescriben enteras: es una lista corta y así se
    // reflejan igual las que quitó que las que añadió.
    await _client
        .from('book_reactions')
        .delete()
        .eq('user_id', _usuario)
        .eq('book_id', feedback.bookId);

    if (feedback.reactions.isNotEmpty) {
      await _client.from('book_reactions').insert([
        for (final reaccion in feedback.reactions)
          {
            'user_id': _usuario,
            'book_id': feedback.bookId,
            'reaction': reaccion.storageName,
          },
      ]);
    }
  }
}
