import '../entities/reading_progress.dart';

/// Persistencia del avance de lectura.
///
/// Hoy es local (el progreso debe sobrevivir sin cuenta ni conexión). Cuando
/// haya sesión, la implementación sincronizará contra Supabase sin que la
/// pantalla cambie.
abstract interface class ReadingProgressRepository {
  Future<List<ReadingProgress>> fetchAll();

  Future<void> save(ReadingProgress progress);

  Future<void> remove(String bookId);
}
