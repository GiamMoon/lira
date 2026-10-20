import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/activity_response.dart';
import '../../domain/repositories/activity_response_repository.dart';

/// Las creaciones del estudiante, guardadas en su espacio de la nube.
///
/// `is_shared` se queda en `false`: lo que escribe es suyo y no aparece en
/// ningún sitio salvo que un día decida compartirlo.
class SupabaseActivityResponseRepository
    implements ActivityResponseRepository {
  const SupabaseActivityResponseRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'activity_responses';

  String get _usuario => _client.auth.currentUser!.id;

  @override
  Future<List<ActivityResponse>> fetchAll() async {
    final filas = await _client
        .from(_table)
        .select('activity_id, content, is_shared, created_at')
        .eq('user_id', _usuario);

    return filas
        .map(
          (fila) => ActivityResponse(
            activityId: fila['activity_id'] as String,
            content: (fila['content'] as String?) ?? '',
            createdAt:
                DateTime.tryParse((fila['created_at'] as String?) ?? '') ??
                DateTime.now(),
            isShared: (fila['is_shared'] as bool?) ?? false,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> save(ActivityResponse response) async {
    await _client.from(_table).upsert({
      'user_id': _usuario,
      'activity_id': response.activityId,
      'content': response.content,
      'is_shared': response.isShared,
      'created_at': response.createdAt.toIso8601String(),
    }, onConflict: 'user_id,activity_id');
  }
}
