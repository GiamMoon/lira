import '../entities/chapter.dart';

/// Origen del texto de una obra, ordenado por posición.
abstract interface class ChapterRepository {
  Future<List<Chapter>> fetchChapters(String bookId);
}
