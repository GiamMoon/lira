import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../dto/book_dto.dart';

/// Catálogo servido por Supabase.
///
/// Sólo lee obras publicadas; el filtro también está en las políticas RLS, de
/// modo que un cliente manipulado tampoco vería borradores.
class SupabaseBookRepository implements BookRepository {
  const SupabaseBookRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'books';

  @override
  Future<List<Book>> fetchCatalog() async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('is_published', true)
        // `ascending` es false por defecto en postgrest-dart: sin esto el
        // catálogo sale de la Z a la A.
        .order('title', ascending: true);

    return rows
        .map((row) => BookDto.fromJson(row).toDomain())
        .toList(growable: false);
  }

  @override
  Future<Book?> fetchBook(String id) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .eq('is_published', true)
        .maybeSingle();

    return row == null ? null : BookDto.fromJson(row).toDomain();
  }
}
