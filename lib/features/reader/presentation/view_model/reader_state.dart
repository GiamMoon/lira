import 'package:flutter/foundation.dart';

import '../../../library/domain/entities/book.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/activity_response.dart';
import '../../domain/entities/chapter.dart';

/// Estado del lector.
@immutable
class ReaderState {
  const ReaderState({
    required this.book,
    required this.chapters,
    required this.activities,
    required this.responses,
    required this.currentIndex,
    this.isFinished = false,
  });

  final Book book;
  final List<Chapter> chapters;
  final List<Activity> activities;
  final Map<String, ActivityResponse> responses;

  /// Capítulo que se está leyendo ahora mismo.
  final int currentIndex;

  /// El estudiante acaba de terminar la obra en esta sesión.
  final bool isFinished;

  bool get hasContent => chapters.isNotEmpty;

  Chapter? get currentChapter =>
      currentIndex >= 0 && currentIndex < chapters.length
      ? chapters[currentIndex]
      : null;

  bool get isFirstChapter => currentIndex <= 0;
  bool get isLastChapter => currentIndex >= chapters.length - 1;

  /// Capítulos completados: es lo que se persiste como progreso.
  int get chaptersRead => isFinished ? chapters.length : currentIndex;

  double get fraction =>
      chapters.isEmpty ? 0 : (chaptersRead / chapters.length).clamp(0.0, 1.0);

  /// Dinámicas ancladas al capítulo actual. Vacío es lo normal: la lectura es
  /// lo principal y las actividades aparecen sólo de vez en cuando.
  List<Activity> get currentActivities {
    final chapter = currentChapter;
    if (chapter == null) return const <Activity>[];
    return activities
        .where((activity) => activity.chapterId == chapter.id)
        .toList(growable: false);
  }

  ActivityResponse? responseFor(String activityId) => responses[activityId];

  ReaderState copyWith({
    List<Chapter>? chapters,
    List<Activity>? activities,
    Map<String, ActivityResponse>? responses,
    int? currentIndex,
    bool? isFinished,
  }) => ReaderState(
    book: book,
    chapters: chapters ?? this.chapters,
    activities: activities ?? this.activities,
    responses: responses ?? this.responses,
    currentIndex: currentIndex ?? this.currentIndex,
    isFinished: isFinished ?? this.isFinished,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderState &&
          other.book == book &&
          listEquals(other.chapters, chapters) &&
          listEquals(other.activities, activities) &&
          mapEquals(other.responses, responses) &&
          other.currentIndex == currentIndex &&
          other.isFinished == isFinished;

  @override
  int get hashCode => Object.hash(
    book,
    Object.hashAll(chapters),
    Object.hashAll(activities),
    Object.hashAll(responses.values),
    currentIndex,
    isFinished,
  );
}
