import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/reading_progress_repository.dart';
import '../dto/reading_progress_dto.dart';

/// Progreso guardado en la nube, atado al usuario de la sesión.
///
/// No hace falta filtrar por `user_id` para leer —las políticas RLS ya sólo
/// devuelven las filas propias— pero se filtra igual: deja explícito en el
/// código lo que está pasando y no depende de que la política siga ahí.
class SupabaseReadingProgressRepository implements ReadingProgressRepository {
  const SupabaseReadingProgressRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'reading_progress';

  String get _usuario => _client.auth.currentUser!.id;

  @override
  Future<List<ReadingProgress>> fetchAll() async {
    final filas = await _client.from(_table).select().eq('user_id', _usuario);

    return filas
        .map((fila) => ReadingProgressDto.fromJson(fila).toDomain())
        .toList(growable: false);
  }

  @override
  Future<void> save(ReadingProgress progress) async {
    final fila = ReadingProgressDto.fromDomain(progress).toJson()
      ..['user_id'] = _usuario;

    // La clave primaria es (user_id, book_id): el upsert actualiza la fila del
    // libro en vez de acumular una por cada vez que se avanza.
    await _client.from(_table).upsert(fila, onConflict: 'user_id,book_id');
  }

  @override
  Future<void> remove(String bookId) async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', _usuario)
        .eq('book_id', bookId);
  }
}
