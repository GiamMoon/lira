import 'dart:convert';

import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/book_feedback.dart';
import '../../domain/entities/book_reaction.dart';
import '../../domain/repositories/book_feedback_repository.dart';

/// Opiniones guardadas en el dispositivo.
///
/// El formato JSON es **el mismo** que espera Supabase (`reaction` con los
/// nombres de `book_reactions`, `stars` como en `book_ratings`), así que
/// sincronizar el día que haya sesión será copiar, no traducir.
class LocalBookFeedbackRepository implements BookFeedbackRepository {
  const LocalBookFeedbackRepository(this._store);

  final KeyValueStore _store;

  @override
  Future<BookFeedback?> fetchFor(String bookId) async {
    final entry = _read()[bookId];
    if (entry == null) return null;

    final reactions = (entry['reactions'] as List<dynamic>? ?? <dynamic>[])
        .map((value) => BookReaction.fromStorage(value as String))
        .nonNulls
        .toSet();

    return BookFeedback(
      bookId: bookId,
      reactions: reactions,
      stars: (entry['stars'] as num?)?.toInt(),
      comment: entry['comment'] as String?,
      createdAt:
          DateTime.tryParse((entry['created_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  @override
  Future<void> save(BookFeedback feedback) async {
    final entries = _read()
      ..[feedback.bookId] = <String, dynamic>{
        'reactions': feedback.reactions
            .map((reaction) => reaction.storageName)
            .toList(growable: false),
        'stars': feedback.stars,
        'comment': feedback.comment,
        'created_at': feedback.createdAt.toIso8601String(),
      };

    await _store.writeString(StorageKeys.bookFeedback, jsonEncode(entries));
  }

  Map<String, Map<String, dynamic>> _read() {
    final raw = _store.readString(StorageKeys.bookFeedback);
    if (raw == null || raw.isEmpty) return <String, Map<String, dynamic>>{};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
      );
    } on FormatException {
      return <String, Map<String, dynamic>>{};
    }
  }
}
