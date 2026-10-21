import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_policy.dart';

import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../dto/activity_dto.dart';

class SupabaseActivityRepository implements ActivityRepository {
  const SupabaseActivityRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'activities';

  @override
  Future<List<Activity>> fetchActivities(String bookId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('book_id', bookId)
        .timeout(NetworkPolicy.requestTimeout);

    return rows
        .map((row) => ActivityDto.fromJson(row).toDomain())
        .toList(growable: false);
  }
}
