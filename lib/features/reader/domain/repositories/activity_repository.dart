import '../entities/activity.dart';

/// Dinámicas disponibles para una obra.
///
/// Que una obra no tenga ninguna es perfectamente válido: la lectura sigue
/// siendo lo principal y las actividades aparecen "de vez en cuando".
abstract interface class ActivityRepository {
  Future<List<Activity>> fetchActivities(String bookId);
}
