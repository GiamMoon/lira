import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_policy.dart';

import '../../domain/entities/chapter.dart';
import '../../domain/repositories/chapter_repository.dart';
import '../dto/chapter_dto.dart';

class SupabaseChapterRepository implements ChapterRepository {
  const SupabaseChapterRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'chapters';

  @override
  Future<List<Chapter>> fetchChapters(String bookId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('book_id', bookId)
        .order('position', ascending: true)
        .timeout(NetworkPolicy.requestTimeout);

    return rows
        .map((row) => ChapterDto.fromJson(row).toDomain())
        .toList(growable: false);
  }
}
