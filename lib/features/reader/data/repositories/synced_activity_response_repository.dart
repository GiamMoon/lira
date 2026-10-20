import 'dart:developer' as developer;

import '../../domain/entities/activity_response.dart';
import '../../domain/repositories/activity_response_repository.dart';

/// Creaciones en el dispositivo **y** en la nube.
///
/// Mismas dos reglas que el progreso: el dispositivo nunca falla, y al leer
/// gana la versión más reciente de cada dinámica, copiando a cada lado lo que
/// le falte. Lo que el estudiante escribió sin sesión sube solo en cuanto la
/// hay.
class SyncedActivityResponseRepository implements ActivityResponseRepository {
  const SyncedActivityResponseRepository(this._local, this._remoto);

  final ActivityResponseRepository _local;
  final ActivityResponseRepository _remoto;

  @override
  Future<List<ActivityResponse>> fetchAll() async {
    final locales = await _local.fetchAll();

    final List<ActivityResponse> remotos;
    try {
      remotos = await _remoto.fetchAll();
    } on Object catch (error) {
      developer.log(
        'No se pudieron leer las creaciones de la nube; se usan las locales',
        name: 'Lira.sync',
        error: error,
      );
      return locales;
    }

    final fusionado = <String, ActivityResponse>{};
    for (final respuesta in [...locales, ...remotos]) {
      final actual = fusionado[respuesta.activityId];
      if (actual == null || respuesta.createdAt.isAfter(actual.createdAt)) {
        fusionado[respuesta.activityId] = respuesta;
      }
    }

    final enLocal = <String, ActivityResponse>{
      for (final r in locales) r.activityId: r,
    };
    final enRemoto = <String, ActivityResponse>{
      for (final r in remotos) r.activityId: r,
    };

    for (final ganadora in fusionado.values) {
      if (enLocal[ganadora.activityId] != ganadora) {
        await _local.save(ganadora);
      }
      if (enRemoto[ganadora.activityId] != ganadora) {
        try {
          await _remoto.save(ganadora);
        } on Object catch (error) {
          developer.log(
            'No se pudo subir la creación de ${ganadora.activityId}',
            name: 'Lira.sync',
            error: error,
          );
        }
      }
    }

    return fusionado.values.toList(growable: false);
  }

  @override
  Future<void> save(ActivityResponse response) async {
    await _local.save(response);
    try {
      await _remoto.save(response);
    } on Object catch (error) {
      developer.log(
        'Creación guardada en el dispositivo; la nube tendrá que esperar',
        name: 'Lira.sync',
        error: error,
      );
    }
  }
}
