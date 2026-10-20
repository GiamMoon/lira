import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../library/data/library_providers.dart';
import '../../../library/domain/entities/reading_progress.dart';
import '../../../reader/data/reader_providers.dart';
import '../../../reader/domain/entities/activity_response.dart';
import 'creations_state.dart';

part 'creations_view_model.g.dart';

/// Reúne lo que el estudiante ha escrito y lo que lleva leído.
///
/// Las respuestas sólo guardan el id de la dinámica, así que aquí se cruzan
/// con el catálogo para poder enseñar la consigna y de qué libro salió. Se
/// hace al vuelo y no se duplica el texto de la consigna en cada respuesta:
/// si un profesor la reescribe, la creación sigue colgando de la buena.
@riverpod
class CreationsViewModel extends _$CreationsViewModel {
  @override
  Future<CreationsState> build() async {
    final libros = await ref.watch(bookRepositoryProvider).fetchCatalog();
    final respuestas = await ref
        .watch(activityResponseRepositoryProvider)
        .fetchAll();

    final porDinamica = <String, ActivityResponse>{
      for (final respuesta in respuestas) respuesta.activityId: respuesta,
    };

    final entradas = <CreationEntry>[];
    if (porDinamica.isNotEmpty) {
      final dinamicas = ref.watch(activityRepositoryProvider);
      for (final libro in libros) {
        for (final dinamica in await dinamicas.fetchActivities(libro.id)) {
          final respuesta = porDinamica[dinamica.id];
          if (respuesta != null) {
            entradas.add(
              CreationEntry(
                bookTitle: libro.title,
                activity: dinamica,
                response: respuesta,
              ),
            );
          }
        }
      }
      entradas.sort(
        (a, b) => b.response.createdAt.compareTo(a.response.createdAt),
      );
    }

    final progreso = await ref
        .watch(readingProgressRepositoryProvider)
        .fetchAll();

    return CreationsState(
      entries: entradas,
      booksFinished: progreso
          .where((p) => p.status == ReadingStatus.finished)
          .length,
      booksStarted: progreso.where((p) => p.chaptersRead > 0).length,
      chaptersRead: progreso.fold<int>(0, (suma, p) => suma + p.chaptersRead),
    );
  }
}
