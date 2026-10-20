import 'dart:developer' as developer;

import '../../domain/entities/book_feedback.dart';
import '../../domain/repositories/book_feedback_repository.dart';

/// Opinión de cierre en el dispositivo **y** en la nube.
///
/// Mismas reglas que el resto: se escribe local primero, y al leer gana la
/// versión más reciente.
class SyncedBookFeedbackRepository implements BookFeedbackRepository {
  const SyncedBookFeedbackRepository(this._local, this._remoto);

  final BookFeedbackRepository _local;
  final BookFeedbackRepository _remoto;

  @override
  Future<BookFeedback?> fetchFor(String bookId) async {
    final local = await _local.fetchFor(bookId);

    final BookFeedback? remoto;
    try {
      remoto = await _remoto.fetchFor(bookId);
    } on Object catch (error) {
      developer.log(
        'No se pudo leer la opinión de la nube; se usa la local',
        name: 'Lira.sync',
        error: error,
      );
      return local;
    }

    if (local == null && remoto == null) return null;
    if (remoto == null) {
      await _subir(local!);
      return local;
    }
    if (local == null) {
      await _local.save(remoto);
      return remoto;
    }

    final gana = local.createdAt.isAfter(remoto.createdAt) ? local : remoto;
    if (gana != local) await _local.save(gana);
    if (gana != remoto) await _subir(gana);
    return gana;
  }

  @override
  Future<void> save(BookFeedback feedback) async {
    await _local.save(feedback);
    await _subir(feedback);
  }

  Future<void> _subir(BookFeedback feedback) async {
    try {
      await _remoto.save(feedback);
    } on Object catch (error) {
      developer.log(
        'Opinión guardada en el dispositivo; la nube tendrá que esperar',
        name: 'Lira.sync',
        error: error,
      );
    }
  }
}
