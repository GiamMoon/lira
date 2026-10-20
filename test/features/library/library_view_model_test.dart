import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lira/features/library/data/library_providers.dart';
import 'package:lira/features/library/domain/entities/book.dart';
import 'package:lira/features/library/domain/entities/reading_progress.dart';
import 'package:lira/features/library/domain/repositories/book_repository.dart';
import 'package:lira/features/library/domain/repositories/reading_progress_repository.dart';
import 'package:lira/features/library/presentation/view_model/library_state.dart';
import 'package:lira/features/library/presentation/view_model/library_view_model.dart';

const Book _cuento = Book(
  id: 'el-almohadon-de-plumas',
  title: 'El almohadón de plumas',
  author: 'Horacio Quiroga',
  synopsis: 'Una casa demasiado silenciosa.',
  category: BookCategory.cuento,
  chapterCount: 3,
  minutesToRead: 12,
);

const Book _poemario = Book(
  id: 'los-heraldos-negros',
  title: 'Los heraldos negros',
  author: 'César Vallejo',
  synopsis: 'Hay golpes en la vida.',
  category: BookCategory.poesia,
  chapterCount: 6,
  minutesToRead: 35,
);

class _FakeBookRepository implements BookRepository {
  @override
  Future<List<Book>> fetchCatalog() async => const <Book>[_cuento, _poemario];

  @override
  Future<Book?> fetchBook(String id) async =>
      id == _cuento.id ? _cuento : (id == _poemario.id ? _poemario : null);
}

/// Repositorio de progreso en memoria: verifica que el ViewModel **persiste**,
/// no sólo que cambia su estado interno.
class _InMemoryProgressRepository implements ReadingProgressRepository {
  final Map<String, ReadingProgress> saved = <String, ReadingProgress>{};

  @override
  Future<List<ReadingProgress>> fetchAll() async => saved.values.toList();

  @override
  Future<void> save(ReadingProgress progress) async =>
      saved[progress.bookId] = progress;

  @override
  Future<void> remove(String bookId) async => saved.remove(bookId);
}

({ProviderContainer container, _InMemoryProgressRepository progress})
_buildContainer({List<ReadingProgress> seed = const <ReadingProgress>[]}) {
  final progress = _InMemoryProgressRepository();
  for (final item in seed) {
    progress.saved[item.bookId] = item;
  }
  final container = ProviderContainer(
    overrides: [
      bookRepositoryProvider.overrideWithValue(_FakeBookRepository()),
      readingProgressRepositoryProvider.overrideWithValue(progress),
    ],
  );
  addTearDown(container.dispose);
  return (container: container, progress: progress);
}

void main() {
  group('LibraryViewModel', () {
    test('carga el catálogo', () async {
      final harness = _buildContainer();

      final state = await harness.container.read(
        libraryViewModelProvider.future,
      );

      expect(state.books, hasLength(2));
      expect(state.currentBook, isNull);
    });

    test('filtra por categoría sin tocar el catálogo', () async {
      final harness = _buildContainer();
      await harness.container.read(libraryViewModelProvider.future);

      harness.container
          .read(libraryViewModelProvider.notifier)
          .filterByCategory(BookCategory.poesia);

      final state = harness.container.read(libraryViewModelProvider).requireValue;
      expect(state.visibleBooks, <Book>[_poemario]);
      expect(state.books, hasLength(2));
    });

    test('busca por autor sin distinguir mayúsculas', () async {
      final harness = _buildContainer();
      await harness.container.read(libraryViewModelProvider.future);

      harness.container
          .read(libraryViewModelProvider.notifier)
          .search('quiroga');

      final state = harness.container.read(libraryViewModelProvider).requireValue;
      expect(state.visibleBooks, <Book>[_cuento]);
    });

    test('empezar un libro lo persiste y lo deja como lectura actual', () async {
      final harness = _buildContainer();
      await harness.container.read(libraryViewModelProvider.future);

      await harness.container
          .read(libraryViewModelProvider.notifier)
          .startReading(_cuento);

      final state = harness.container.read(libraryViewModelProvider).requireValue;
      expect(state.currentBook, _cuento);
      expect(harness.progress.saved[_cuento.id]?.status, ReadingStatus.reading);
    });

    test('dejar un libro conserva el avance', () async {
      // Se siembra el progreso antes de construir el ViewModel: así se prueba
      // también que el avance previo se recupera del repositorio al arrancar.
      final harness = _buildContainer(
        seed: <ReadingProgress>[
          ReadingProgress(
            bookId: _cuento.id,
            chaptersRead: 2,
            chapterCount: 3,
            status: ReadingStatus.reading,
            updatedAt: DateTime(2026, 9, 16, 9),
          ),
        ],
      );
      final loaded = await harness.container.read(
        libraryViewModelProvider.future,
      );
      expect(loaded.currentBook, _cuento);

      await harness.container
          .read(libraryViewModelProvider.notifier)
          .abandon(_cuento);

      final stored = harness.progress.saved[_cuento.id]!;
      expect(stored.status, ReadingStatus.abandoned);
      expect(stored.chaptersRead, 2, reason: 'dejar un libro no borra nada');

      final state = harness.container.read(libraryViewModelProvider).requireValue;
      expect(
        state.currentBook,
        isNull,
        reason: 'un libro dejado sale de «Sigue donde lo dejaste»',
      );
    });
  });

  group('LibraryState', () {
    test('la lectura activa más reciente gana', () {
      final now = DateTime(2026, 9, 16, 10);
      final state = LibraryState(
        books: const <Book>[_cuento, _poemario],
        progressByBook: <String, ReadingProgress>{
          _cuento.id: ReadingProgress(
            bookId: _cuento.id,
            chaptersRead: 1,
            chapterCount: 3,
            status: ReadingStatus.reading,
            updatedAt: now,
          ),
          _poemario.id: ReadingProgress(
            bookId: _poemario.id,
            chaptersRead: 4,
            chapterCount: 6,
            status: ReadingStatus.reading,
            updatedAt: now.add(const Duration(hours: 2)),
          ),
        },
      );

      expect(state.currentBook, _poemario);
      expect(state.currentProgress?.percent, 67);
    });
  });
}
