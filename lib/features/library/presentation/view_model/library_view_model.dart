import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/library_providers.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_progress.dart';
import 'library_state.dart';

part 'library_view_model.g.dart';

/// ViewModel de la biblioteca.
///
/// Carga catálogo y progreso, y expone comandos de intención: filtrar, buscar,
/// empezar y dejar un libro. La vista no toca repositorios.
@riverpod
class LibraryViewModel extends _$LibraryViewModel {
  @override
  Future<LibraryState> build() async {
    final books = await ref.watch(bookRepositoryProvider).fetchCatalog();
    final progress = await ref
        .watch(readingProgressRepositoryProvider)
        .fetchAll();

    return LibraryState(
      books: books,
      progressByBook: <String, ReadingProgress>{
        for (final item in progress) item.bookId: item,
      },
    );
  }

  void filterByCategory(BookCategory? category) =>
      _mutate((state) => state.copyWith(category: category));

  void search(String query) => _mutate((state) => state.copyWith(query: query));

  /// Abre (o reabre) un libro. Reabrir uno abandonado lo devuelve a la
  /// estantería activa sin perder los capítulos ya leídos.
  Future<void> startReading(Book book) async {
    final current = state.value;
    if (current == null) return;

    final existing = current.progressByBook[book.id];
    final now = DateTime.now();
    final updated =
        existing?.copyWith(status: ReadingStatus.reading, updatedAt: now) ??
        ReadingProgress.started(
          bookId: book.id,
          chapterCount: book.chapterCount,
          now: now,
        );

    await ref.read(readingProgressRepositoryProvider).save(updated);
    _mutate(
      (state) => state.copyWith(
        progressByBook: <String, ReadingProgress>{
          ...state.progressByBook,
          book.id: updated,
        },
      ),
    );
  }

  /// Dejar un libro nunca borra el avance: sólo lo saca de "leyendo".
  /// Es una regla de producto, no un detalle de implementación.
  Future<void> abandon(Book book) async {
    final current = state.value;
    final existing = current?.progressByBook[book.id];
    if (existing == null) return;

    final updated = existing.copyWith(
      status: ReadingStatus.abandoned,
      updatedAt: DateTime.now(),
    );

    await ref.read(readingProgressRepositoryProvider).save(updated);
    _mutate(
      (state) => state.copyWith(
        progressByBook: <String, ReadingProgress>{
          ...state.progressByBook,
          book.id: updated,
        },
      ),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  void _mutate(LibraryState Function(LibraryState state) transform) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData<LibraryState>(transform(current));
  }
}
