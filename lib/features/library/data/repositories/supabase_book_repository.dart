import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_policy.dart';

import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../dto/book_dto.dart';

/// Consulta únicamente las obras publicadas, también protegidas por RLS.
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
        .order('title', ascending: true)
        .timeout(NetworkPolicy.requestTimeout);

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
        .maybeSingle()
        .timeout(NetworkPolicy.requestTimeout);

    return row == null ? null : BookDto.fromJson(row).toDomain();
  }
}
