import 'dart:developer' as developer;

import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/reading_progress_repository.dart';

/// Progreso en el dispositivo **y** en la nube.
///
/// Las dos reglas que lo gobiernan:
///
/// 1. **El dispositivo nunca falla.** Se escribe siempre en local primero, así
///    que un estudiante sin datos móviles sigue leyendo y guardando. La nube
///    es lo que se añade, no lo que sostiene.
/// 2. **Gana lo más reciente.** Al leer se fusionan las dos fuentes por
///    `updatedAt`, y lo que falte en cada lado se copia. Así el avance que
///    tenía guardado en el teléfono antes de haber sesión sube solo la primera
///    vez que hay conexión.
class SyncedReadingProgressRepository implements ReadingProgressRepository {
  const SyncedReadingProgressRepository(this._local, this._remoto);

  final ReadingProgressRepository _local;
  final ReadingProgressRepository _remoto;

  @override
  Future<List<ReadingProgress>> fetchAll() async {
    final locales = await _local.fetchAll();

    final List<ReadingProgress> remotos;
    try {
      remotos = await _remoto.fetchAll();
    } on Object catch (error) {
      // Sin red o sin permisos: se lee lo del dispositivo y ya está.
      developer.log(
        'No se pudo leer el progreso de la nube; se usa el local',
        name: 'Lira.sync',
        error: error,
      );
      return locales;
    }

    final fusionado = <String, ReadingProgress>{};
    for (final progreso in [...locales, ...remotos]) {
      final actual = fusionado[progreso.bookId];
      if (actual == null || progreso.updatedAt.isAfter(actual.updatedAt)) {
        fusionado[progreso.bookId] = progreso;
      }
    }

    await _igualar(fusionado, locales, remotos);
    return fusionado.values.toList(growable: false);
  }

  /// Deja las dos fuentes con la versión ganadora de cada libro.
  Future<void> _igualar(
    Map<String, ReadingProgress> fusionado,
    List<ReadingProgress> locales,
    List<ReadingProgress> remotos,
  ) async {
    final porLibroLocal = <String, ReadingProgress>{
      for (final p in locales) p.bookId: p,
    };
    final porLibroRemoto = <String, ReadingProgress>{
      for (final p in remotos) p.bookId: p,
    };

    for (final ganador in fusionado.values) {
      if (porLibroLocal[ganador.bookId] != ganador) {
        await _local.save(ganador);
      }
      if (porLibroRemoto[ganador.bookId] != ganador) {
        try {
          await _remoto.save(ganador);
        } on Object catch (error) {
          developer.log(
            'No se pudo subir el progreso de ${ganador.bookId}',
            name: 'Lira.sync',
            error: error,
          );
        }
      }
    }
  }

  @override
  Future<void> save(ReadingProgress progress) async {
    // Local primero: es el que no puede fallar.
    await _local.save(progress);
    try {
      await _remoto.save(progress);
    } on Object catch (error) {
      developer.log(
        'Progreso guardado en el dispositivo; la nube tendrá que esperar',
        name: 'Lira.sync',
        error: error,
      );
    }
  }

  @override
  Future<void> remove(String bookId) async {
    await _local.remove(bookId);
    try {
      await _remoto.remove(bookId);
    } on Object catch (error) {
      developer.log(
        'No se pudo borrar el progreso remoto de $bookId',
        name: 'Lira.sync',
        error: error,
      );
    }
  }
}
