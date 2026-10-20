import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../sources/book_seed.dart';

/// Catálogo local de respaldo.
///
/// Permite desarrollar, hacer demos y correr tests sin credenciales ni red.
class SeedBookRepository implements BookRepository {
  const SeedBookRepository();

  @override
  Future<List<Book>> fetchCatalog() async => BookSeed.catalog;

  @override
  Future<Book?> fetchBook(String id) async {
    for (final book in BookSeed.catalog) {
      if (book.id == id) return book;
    }
    return null;
  }
}
