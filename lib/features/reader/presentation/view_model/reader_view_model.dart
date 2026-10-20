import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../library/data/library_providers.dart';
import '../../../library/domain/book_not_found_exception.dart';
import '../../../library/domain/entities/reading_progress.dart';
import '../../data/reader_providers.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/activity_response.dart';
import 'reader_state.dart';

part 'reader_view_model.g.dart';

/// ViewModel del lector, uno por obra abierta.
///
/// Reglas de producto que se cumplen aquí, no en la UI:
/// - el avance se guarda solo, sin botón de "guardar";
/// - dejar un libro conserva el progreso;
/// - responder una dinámica es siempre opcional y nunca bloquea la lectura.
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

    // Se retoma justo donde quedó. Si ya lo había terminado, se reabre en el
    // último capítulo en vez de mandarlo fuera de rango.
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

  /// Avanza un capítulo y persiste el progreso. En el último, cierra la obra.
  Future<void> nextChapter() async {
    final current = state.value;
    if (current == null || !current.hasContent) return;

    if (current.isLastChapter) {
      await _saveProgress(current, chaptersRead: current.chapters.length,
          status: ReadingStatus.finished);
      state = AsyncData<ReaderState>(current.copyWith(isFinished: true));
      return;
    }

    final next = current.currentIndex + 1;
    await _saveProgress(current, chaptersRead: next,
        status: ReadingStatus.reading);
    state = AsyncData<ReaderState>(current.copyWith(currentIndex: next));
  }

  /// Volver atrás no reduce el progreso: releer no es desleer.
  void previousChapter() {
    final current = state.value;
    if (current == null || current.isFirstChapter) return;
    state = AsyncData<ReaderState>(
      current.copyWith(currentIndex: current.currentIndex - 1),
    );
  }

  /// Guarda lo que el estudiante creó. No valida nada: no hay respuesta
  /// correcta y tampoco una longitud correcta.
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

  /// "Guardar y salir": el libro sale de la estantería activa y el avance
  /// queda intacto para cuando vuelva.
  Future<void> leaveBook() async {
    final current = state.value;
    if (current == null) return;
    await _saveProgress(current, chaptersRead: current.chaptersRead,
        status: ReadingStatus.abandoned);
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
  }) => ref
      .read(readingProgressRepositoryProvider)
      .save(
        ReadingProgress(
          bookId: current.book.id,
          chaptersRead: chaptersRead,
          chapterCount: current.chapters.length,
          status: status,
          updatedAt: DateTime.now(),
        ),
      );
}
