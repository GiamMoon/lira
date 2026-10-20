import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/chapter.dart';
import '../../domain/repositories/chapter_repository.dart';
import '../dto/chapter_dto.dart';

/// Capítulos servidos por Supabase.
///
/// Se piden ordenados por `position`: el orden de lectura es responsabilidad
/// del servidor, no del cliente.
class SupabaseChapterRepository implements ChapterRepository {
  const SupabaseChapterRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'chapters';

  @override
  Future<List<Chapter>> fetchChapters(String bookId) async {
    // ¡`ascending` es false por defecto en postgrest-dart! Sin esto el libro
    // se lee del final al principio.
    final rows = await _client
        .from(_table)
        .select()
        .eq('book_id', bookId)
        .order('position', ascending: true);

    return rows
        .map((row) => ChapterDto.fromJson(row).toDomain())
        .toList(growable: false);
  }
}
