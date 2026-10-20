import '../entities/book_feedback.dart';

/// Persistencia de la reacción, la calificación y el comentario de una obra.
abstract interface class BookFeedbackRepository {
  /// Lo que ya dejó para esta obra, o `null` si aún no ha dicho nada.
  Future<BookFeedback?> fetchFor(String bookId);

  Future<void> save(BookFeedback feedback);
}
