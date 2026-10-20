import '../entities/book.dart';

/// Origen del catálogo de obras.
///
/// La implementación puede ser Supabase, una semilla local o una caché; la
/// biblioteca no nota la diferencia.
abstract interface class BookRepository {
  Future<List<Book>> fetchCatalog();

  /// Una obra concreta. Devuelve `null` si no existe: el lector puede
  /// abrirse por enlace directo con un id que ya no esté publicado.
  Future<Book?> fetchBook(String id);
}
