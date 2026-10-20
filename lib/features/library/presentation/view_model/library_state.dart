import 'package:flutter/foundation.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/reading_progress.dart';

/// Todo lo que la pantalla de biblioteca necesita saber, en un solo objeto.
///
/// Los filtros viven aquí (no en el widget) para que se puedan probar sin
/// levantar UI y para que sobrevivan a un rebuild.
@immutable
class LibraryState {
  const LibraryState({
    required this.books,
    required this.progressByBook,
    this.category,
    this.query = '',
  });

  final List<Book> books;
  final Map<String, ReadingProgress> progressByBook;

  /// `null` significa "Todos".
  final BookCategory? category;
  final String query;

  /// Centinela para distinguir "no toques la categoría" de "ponla en null".
  static const Object _keep = Object();

  List<Book> get visibleBooks {
    final needle = query.trim().toLowerCase();

    return books.where((book) {
      final matchesCategory = category == null || book.category == category;
      final matchesQuery =
          needle.isEmpty ||
          book.title.toLowerCase().contains(needle) ||
          book.author.toLowerCase().contains(needle);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  bool get hasResults => visibleBooks.isNotEmpty;

  bool get isFiltering => category != null || query.trim().isNotEmpty;

  /// La lectura activa más reciente: lo que alimenta "Sigue donde lo dejaste".
  ReadingProgress? get currentProgress {
    ReadingProgress? latest;
    for (final progress in progressByBook.values) {
      if (!progress.isActive) continue;
      if (latest == null || progress.updatedAt.isAfter(latest.updatedAt)) {
        latest = progress;
      }
    }
    return latest;
  }

  Book? get currentBook {
    final progress = currentProgress;
    if (progress == null) return null;
    for (final book in books) {
      if (book.id == progress.bookId) return book;
    }
    return null;
  }

  ReadingProgress? progressFor(String bookId) => progressByBook[bookId];

  LibraryState copyWith({
    List<Book>? books,
    Map<String, ReadingProgress>? progressByBook,
    Object? category = _keep,
    String? query,
  }) => LibraryState(
    books: books ?? this.books,
    progressByBook: progressByBook ?? this.progressByBook,
    category: identical(category, _keep)
        ? this.category
        : category as BookCategory?,
    query: query ?? this.query,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryState &&
          listEquals(other.books, books) &&
          mapEquals(other.progressByBook, progressByBook) &&
          other.category == category &&
          other.query == query;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(books),
    Object.hashAll(progressByBook.values),
    category,
    query,
  );
}
