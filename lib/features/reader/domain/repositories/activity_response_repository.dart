import '../entities/activity_response.dart';

/// Persistencia de las creaciones del estudiante.
abstract interface class ActivityResponseRepository {
  Future<List<ActivityResponse>> fetchAll();

  Future<void> save(ActivityResponse response);
}
