import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lira/features/library/data/library_providers.dart';
import 'package:lira/features/library/domain/book_not_found_exception.dart';
import 'package:lira/features/library/domain/entities/book.dart';
import 'package:lira/features/library/domain/entities/reading_progress.dart';
import 'package:lira/features/library/domain/repositories/book_repository.dart';
import 'package:lira/features/library/domain/repositories/reading_progress_repository.dart';
import 'package:lira/features/reader/data/reader_providers.dart';
import 'package:lira/features/reader/domain/entities/activity.dart';
import 'package:lira/features/reader/domain/entities/activity_response.dart';
import 'package:lira/features/reader/domain/entities/chapter.dart';
import 'package:lira/features/reader/domain/entities/content_block.dart';
import 'package:lira/features/reader/domain/repositories/activity_repository.dart';
import 'package:lira/features/reader/domain/repositories/activity_response_repository.dart';
import 'package:lira/features/reader/domain/repositories/chapter_repository.dart';
import 'package:lira/features/reader/presentation/view_model/reader_view_model.dart';

const String _bookId = 'paco-yunque';

const Book _book = Book(
  id: _bookId,
  title: 'Paco Yunque',
  author: 'César Vallejo',
  synopsis: 'El primer día de clase.',
  category: BookCategory.cuento,
  chapterCount: 2,
  minutesToRead: 25,
);

const List<Chapter> _chapters = <Chapter>[
  Chapter(
    id: 'yunque-1',
    bookId: _bookId,
    position: 0,
    title: 'El salón',
    blocks: <ContentBlock>[ParagraphBlock('Paco entró al salón.')],
  ),
  Chapter(
    id: 'yunque-2',
    bookId: _bookId,
    position: 1,
    title: 'El recreo',
    blocks: <ContentBlock>[ParagraphBlock('En el recreo el patio se dividía.')],
  ),
];

const Activity _activity = Activity(
  id: 'yunque-2-que-harias',
  bookId: _bookId,
  chapterId: 'yunque-2',
  kind: ActivityKind.queHarias,
  prompt: '¿Qué haces tú?',
);

class _FakeBookRepository implements BookRepository {
  @override
  Future<List<Book>> fetchCatalog() async => const <Book>[_book];

  @override
  Future<Book?> fetchBook(String id) async => id == _bookId ? _book : null;
}

class _FakeChapterRepository implements ChapterRepository {
  const _FakeChapterRepository(this.chapters);

  final List<Chapter> chapters;

  @override
  Future<List<Chapter>> fetchChapters(String bookId) async => chapters;
}

class _FakeActivityRepository implements ActivityRepository {
  @override
  Future<List<Activity>> fetchActivities(String bookId) async =>
      const <Activity>[_activity];
}

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

class _InMemoryResponseRepository implements ActivityResponseRepository {
  final Map<String, ActivityResponse> saved = <String, ActivityResponse>{};

  @override
  Future<List<ActivityResponse>> fetchAll() async => saved.values.toList();

  @override
  Future<void> save(ActivityResponse response) async =>
      saved[response.activityId] = response;
}

({
  ProviderContainer container,
  _InMemoryProgressRepository progress,
  _InMemoryResponseRepository responses,
})
_buildContainer({
  List<Chapter> chapters = _chapters,
  List<ReadingProgress> seed = const <ReadingProgress>[],
}) {
  final progress = _InMemoryProgressRepository();
  final responses = _InMemoryResponseRepository();
  for (final item in seed) {
    progress.saved[item.bookId] = item;
  }

  final container = ProviderContainer(
    overrides: [
      bookRepositoryProvider.overrideWithValue(_FakeBookRepository()),
      readingProgressRepositoryProvider.overrideWithValue(progress),
      chapterRepositoryProvider.overrideWithValue(
        _FakeChapterRepository(chapters),
      ),
      activityRepositoryProvider.overrideWithValue(_FakeActivityRepository()),
      activityResponseRepositoryProvider.overrideWithValue(responses),
    ],
  );
  addTearDown(container.dispose);

  return (container: container, progress: progress, responses: responses);
}

void main() {
  group('ReaderViewModel', () {
    test('abre por el principio cuando no hay progreso', () async {
      final harness = _buildContainer();

      final state = await harness.container.read(
        readerViewModelProvider(_bookId).future,
      );

      expect(state.currentIndex, 0);
      expect(state.currentChapter?.title, 'El salón');
      expect(state.isFirstChapter, isTrue);
    });

    test('retoma donde quedó', () async {
      final harness = _buildContainer(
        seed: <ReadingProgress>[
          ReadingProgress(
            bookId: _bookId,
            chaptersRead: 1,
            chapterCount: 2,
            status: ReadingStatus.reading,
            updatedAt: DateTime(2026, 9, 16),
          ),
        ],
      );

      final state = await harness.container.read(
        readerViewModelProvider(_bookId).future,
      );

      expect(state.currentIndex, 1);
      expect(state.currentChapter?.title, 'El recreo');
    });

    test('avanzar de capítulo guarda el progreso solo', () async {
      final harness = _buildContainer();
      await harness.container.read(readerViewModelProvider(_bookId).future);

      await harness.container
          .read(readerViewModelProvider(_bookId).notifier)
          .nextChapter();

      final stored = harness.progress.saved[_bookId]!;
      expect(stored.chaptersRead, 1);
      expect(stored.status, ReadingStatus.reading);
    });

    test('terminar el último capítulo cierra la obra', () async {
      final harness = _buildContainer();
      await harness.container.read(readerViewModelProvider(_bookId).future);
      final viewModel = harness.container.read(
        readerViewModelProvider(_bookId).notifier,
      );

      await viewModel.nextChapter();
      await viewModel.nextChapter();

      final state = harness.container
          .read(readerViewModelProvider(_bookId))
          .requireValue;
      expect(state.isFinished, isTrue);
      expect(state.fraction, 1);
      expect(harness.progress.saved[_bookId]!.status, ReadingStatus.finished);
    });

    test('volver atrás no reduce el progreso guardado', () async {
      final harness = _buildContainer();
      await harness.container.read(readerViewModelProvider(_bookId).future);
      final viewModel = harness.container.read(
        readerViewModelProvider(_bookId).notifier,
      );

      await viewModel.nextChapter();
      viewModel.previousChapter();

      final state = harness.container
          .read(readerViewModelProvider(_bookId))
          .requireValue;
      expect(state.currentIndex, 0, reason: 'la vista sí retrocede');
      expect(
        harness.progress.saved[_bookId]!.chaptersRead,
        1,
        reason: 'releer no es desleer',
      );
    });

    test('responder una dinámica la persiste', () async {
      final harness = _buildContainer();
      await harness.container.read(readerViewModelProvider(_bookId).future);

      await harness.container
          .read(readerViewModelProvider(_bookId).notifier)
          .answerActivity(_activity, 'Me pararía al lado de Paco.');

      expect(
        harness.responses.saved[_activity.id]?.content,
        'Me pararía al lado de Paco.',
      );
      final state = harness.container
          .read(readerViewModelProvider(_bookId))
          .requireValue;
      expect(state.responseFor(_activity.id), isNotNull);
    });

    test('las dinámicas se ofrecen sólo en su capítulo', () async {
      final harness = _buildContainer();
      final state = await harness.container.read(
        readerViewModelProvider(_bookId).future,
      );

      expect(state.currentActivities, isEmpty, reason: 'capítulo 1 no tiene');

      await harness.container
          .read(readerViewModelProvider(_bookId).notifier)
          .nextChapter();

      final next = harness.container
          .read(readerViewModelProvider(_bookId))
          .requireValue;
      expect(next.currentActivities, <Activity>[_activity]);
    });

    test('dejar el libro conserva lo leído', () async {
      final harness = _buildContainer();
      await harness.container.read(readerViewModelProvider(_bookId).future);
      final viewModel = harness.container.read(
        readerViewModelProvider(_bookId).notifier,
      );

      await viewModel.nextChapter();
      await viewModel.leaveBook();

      final stored = harness.progress.saved[_bookId]!;
      expect(stored.status, ReadingStatus.abandoned);
      expect(stored.chaptersRead, 1);
    });

    test('una obra sin texto cargado no revienta', () async {
      final harness = _buildContainer(chapters: const <Chapter>[]);

      final state = await harness.container.read(
        readerViewModelProvider(_bookId).future,
      );

      expect(state.hasContent, isFalse);
      expect(state.currentChapter, isNull);
    });

    test('una obra inexistente falla con BookNotFoundException', () async {
      final harness = _buildContainer();
      final provider = readerViewModelProvider('no-existe');

      // Se sostiene una suscripción (sin ella el provider se auto-descarta) y
      // se comprueba el `AsyncValue` en vez de `.future`: esperar el future de
      // un build que falla deja al provider colgado en `loading`.
      final subscription = harness.container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      await pumpEventQueue();

      expect(
        harness.container.read(provider).error,
        isA<BookNotFoundException>(),
      );
    });
  });
}
