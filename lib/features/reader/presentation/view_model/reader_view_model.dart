import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../library/data/library_providers.dart';
import '../../../library/domain/book_not_found_exception.dart';
import '../../../library/domain/entities/reading_progress.dart';
import '../../data/reader_providers.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/activity_response.dart';
import 'reader_state.dart';

part 'reader_view_model.g.dart';

@riverpod
class ReaderViewModel extends _$ReaderViewModel {
  @override
  Future<ReaderState> build(String bookId) async {
    final book = await ref.watch(bookRepositoryProvider).fetchBook(bookId);
    if (book == null) throw BookNotFoundException(bookId);

    final chapters = await ref
        .watch(chapterRepositoryProvider)
        .fetchChapters(bookId);
    final activities = await ref
        .watch(activityRepositoryProvider)
        .fetchActivities(bookId);
    final responses = await ref
        .watch(activityResponseRepositoryProvider)
        .fetchAll();
    final progress = await _currentProgress(bookId);

    // Limita la posición guardada al catálogo actual de capítulos.
    final resumeAt = chapters.isEmpty
        ? 0
        : (progress?.chaptersRead ?? 0).clamp(0, chapters.length - 1);

    return ReaderState(
      book: book,
      chapters: chapters,
      activities: activities,
      responses: <String, ActivityResponse>{
        for (final response in responses) response.activityId: response,
      },
      currentIndex: resumeAt,
    );
  }

  Future<void> nextChapter() async {
    final current = state.value;
    if (current == null || !current.hasContent) return;

    if (current.isLastChapter) {
      await _saveProgress(
        current,
        chaptersRead: current.chapters.length,
        status: ReadingStatus.finished,
      );
      state = AsyncData<ReaderState>(current.copyWith(isFinished: true));
      return;
    }

    final next = current.currentIndex + 1;
    await _saveProgress(
      current,
      chaptersRead: next,
      status: ReadingStatus.reading,
    );
    state = AsyncData<ReaderState>(current.copyWith(currentIndex: next));
  }

  void previousChapter() {
    final current = state.value;
    if (current == null || current.isFirstChapter) return;
    state = AsyncData<ReaderState>(
      current.copyWith(currentIndex: current.currentIndex - 1),
    );
  }

  Future<void> goToChapter(int index) async {
    final current = state.value;
    if (current == null ||
        index < 0 ||
        index >= current.chapters.length ||
        index == current.currentIndex) {
      return;
    }
    await _saveProgress(
      current,
      chaptersRead: index,
      status: ReadingStatus.reading,
    );
    state = AsyncData<ReaderState>(current.copyWith(currentIndex: index));
  }

  Future<void> answerActivity(Activity activity, String content) async {
    final current = state.value;
    if (current == null) return;

    final response = ActivityResponse(
      activityId: activity.id,
      content: content,
      createdAt: DateTime.now(),
    );

    await ref.read(activityResponseRepositoryProvider).save(response);
    state = AsyncData<ReaderState>(
      current.copyWith(
        responses: <String, ActivityResponse>{
          ...current.responses,
          activity.id: response,
        },
      ),
    );
  }

  /// Conserva el avance y retira la obra de las lecturas activas.
  Future<void> leaveBook() async {
    final current = state.value;
    if (current == null) return;
    await _saveProgress(
      current,
      chaptersRead: current.chaptersRead,
      status: ReadingStatus.abandoned,
    );
  }

  Future<ReadingProgress?> _currentProgress(String bookId) async {
    final all = await ref.read(readingProgressRepositoryProvider).fetchAll();
    for (final progress in all) {
      if (progress.bookId == bookId) return progress;
    }
    return null;
  }

  Future<void> _saveProgress(
    ReaderState current, {
    required int chaptersRead,
    required ReadingStatus status,
  }) async {
    final previous = await _currentProgress(current.book.id);
    final furthest = previous != null && previous.chaptersRead > chaptersRead
        ? previous.chaptersRead
        : chaptersRead;
    await ref
        .read(readingProgressRepositoryProvider)
        .save(
          ReadingProgress(
            bookId: current.book.id,
            chaptersRead: furthest,
            chapterCount: current.chapters.length,
            status: status,
            updatedAt: DateTime.now(),
          ),
        );
  }
}
