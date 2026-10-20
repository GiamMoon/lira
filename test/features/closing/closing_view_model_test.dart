import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lira/features/closing/data/closing_providers.dart';
import 'package:lira/features/closing/domain/entities/book_feedback.dart';
import 'package:lira/features/closing/domain/entities/book_reaction.dart';
import 'package:lira/features/closing/domain/repositories/book_feedback_repository.dart';
import 'package:lira/features/closing/presentation/view_model/closing_view_model.dart';
import 'package:lira/features/library/data/library_providers.dart';
import 'package:lira/features/library/domain/entities/book.dart';
import 'package:lira/features/library/domain/repositories/book_repository.dart';

const String _bookId = 'el-almohadon-de-plumas';

const Book _book = Book(
  id: _bookId,
  title: 'El almohadón de plumas',
  author: 'Horacio Quiroga',
  synopsis: 'Una casa demasiado silenciosa.',
  category: BookCategory.cuento,
  chapterCount: 3,
  minutesToRead: 12,
);

class _FakeBookRepository implements BookRepository {
  @override
  Future<List<Book>> fetchCatalog() async => const <Book>[_book];

  @override
  Future<Book?> fetchBook(String id) async => id == _bookId ? _book : null;
}

class _InMemoryFeedbackRepository implements BookFeedbackRepository {
  final Map<String, BookFeedback> saved = <String, BookFeedback>{};

  @override
  Future<BookFeedback?> fetchFor(String bookId) async => saved[bookId];

  @override
  Future<void> save(BookFeedback feedback) async =>
      saved[feedback.bookId] = feedback;
}

({ProviderContainer container, _InMemoryFeedbackRepository feedback})
_buildContainer({BookFeedback? seed}) {
  final feedback = _InMemoryFeedbackRepository();
  if (seed != null) feedback.saved[seed.bookId] = seed;

  final container = ProviderContainer(
    overrides: [
      bookRepositoryProvider.overrideWithValue(_FakeBookRepository()),
      bookFeedbackRepositoryProvider.overrideWithValue(feedback),
    ],
  );
  addTearDown(container.dispose);

  return (container: container, feedback: feedback);
}

void main() {
  group('ClosingViewModel', () {
    test('abre en blanco cuando no dijo nada todavía', () async {
      final harness = _buildContainer();

      final state = await harness.container.read(
        closingViewModelProvider(_bookId).future,
      );

      expect(state.reactions, isEmpty);
      expect(state.stars, isNull);
      expect(state.comment, isEmpty);
      expect(state.hasAnything, isFalse);
    });

    test('las reacciones son multi-selección y se pueden quitar', () async {
      final harness = _buildContainer();
      await harness.container.read(closingViewModelProvider(_bookId).future);
      final viewModel = harness.container.read(
        closingViewModelProvider(_bookId).notifier,
      );

      viewModel
        ..toggleReaction(BookReaction.thoughtful)
        ..toggleReaction(BookReaction.sad);

      expect(
        harness.container
            .read(closingViewModelProvider(_bookId))
            .requireValue
            .reactions,
        <BookReaction>{BookReaction.thoughtful, BookReaction.sad},
      );

      viewModel.toggleReaction(BookReaction.sad);

      expect(
        harness.container
            .read(closingViewModelProvider(_bookId))
            .requireValue
            .reactions,
        <BookReaction>{BookReaction.thoughtful},
      );
    });

    test('tocar la estrella ya marcada quita la calificación', () async {
      final harness = _buildContainer();
      await harness.container.read(closingViewModelProvider(_bookId).future);
      final viewModel = harness.container.read(
        closingViewModelProvider(_bookId).notifier,
      );

      viewModel.setStars(4);
      expect(
        harness.container
            .read(closingViewModelProvider(_bookId))
            .requireValue
            .stars,
        4,
      );

      viewModel.setStars(4);
      expect(
        harness.container
            .read(closingViewModelProvider(_bookId))
            .requireValue
            .stars,
        isNull,
      );
    });

    test('guarda reacciones, estrellas y comentario', () async {
      final harness = _buildContainer();
      await harness.container.read(closingViewModelProvider(_bookId).future);
      final viewModel = harness.container.read(
        closingViewModelProvider(_bookId).notifier,
      );

      viewModel
        ..toggleReaction(BookReaction.surprised)
        ..setStars(5)
        ..setComment('  No me esperaba ese final.  ');
      await viewModel.submit();

      final stored = harness.feedback.saved[_bookId]!;
      expect(stored.reactions, <BookReaction>{BookReaction.surprised});
      expect(stored.stars, 5);
      expect(
        stored.comment,
        'No me esperaba ese final.',
        reason: 'el comentario se guarda recortado',
      );
    });

    test('se puede cerrar sólo con estrellas', () async {
      final harness = _buildContainer();
      await harness.container.read(closingViewModelProvider(_bookId).future);
      final viewModel = harness.container.read(
        closingViewModelProvider(_bookId).notifier,
      );

      viewModel.setStars(3);
      await viewModel.submit();

      final stored = harness.feedback.saved[_bookId]!;
      expect(stored.stars, 3);
      expect(stored.reactions, isEmpty);
      expect(stored.comment, isNull);
    });

    test('se puede cerrar sin decir absolutamente nada', () async {
      final harness = _buildContainer();
      await harness.container.read(closingViewModelProvider(_bookId).future);

      await harness.container
          .read(closingViewModelProvider(_bookId).notifier)
          .submit();

      expect(harness.feedback.saved[_bookId], isNotNull);
      expect(harness.feedback.saved[_bookId]!.isEmpty, isTrue);
    });

    test('al reabrir recupera lo que ya había dicho', () async {
      final harness = _buildContainer(
        seed: BookFeedback(
          bookId: _bookId,
          reactions: const <BookReaction>{BookReaction.angry},
          stars: 2,
          comment: 'No era para mí.',
          createdAt: DateTime(2026, 9, 16),
        ),
      );

      final state = await harness.container.read(
        closingViewModelProvider(_bookId).future,
      );

      expect(state.reactions, <BookReaction>{BookReaction.angry});
      expect(state.stars, 2);
      expect(state.comment, 'No era para mí.');
    });
  });
}
