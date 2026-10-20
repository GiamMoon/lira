import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../sources/activity_seed.dart';

class SeedActivityRepository implements ActivityRepository {
  const SeedActivityRepository();

  @override
  Future<List<Activity>> fetchActivities(String bookId) async =>
      ActivitySeed.forBook(bookId);
}
