import '../../domain/entities/chapter.dart';
import '../../domain/repositories/chapter_repository.dart';
import '../sources/chapter_seed.dart';

class SeedChapterRepository implements ChapterRepository {
  const SeedChapterRepository();

  @override
  Future<List<Chapter>> fetchChapters(String bookId) async =>
      ChapterSeed.forBook(bookId);
}
