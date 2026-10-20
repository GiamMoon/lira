import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/network/supabase_providers.dart';
import '../../../core/network/supabase_session.dart';
import '../domain/repositories/book_repository.dart';
import '../domain/repositories/reading_progress_repository.dart';
import 'repositories/local_reading_progress_repository.dart';
import 'repositories/seed_book_repository.dart';
import 'repositories/supabase_book_repository.dart';
import 'repositories/supabase_reading_progress_repository.dart';
import 'repositories/synced_reading_progress_repository.dart';

part 'library_providers.g.dart';

/// Elige el origen del catálogo según la configuración de entorno.
///
/// Este `if` es el único sitio de toda la app que sabe si hay backend: el
/// ViewModel, la vista y los tests hablan siempre con [BookRepository].
@Riverpod(keepAlive: true)
BookRepository bookRepository(Ref ref) => AppConfig.hasRemoteBackend
    ? SupabaseBookRepository(ref.watch(supabaseClientProvider))
    : const SeedBookRepository();

/// El progreso se guarda siempre en el dispositivo, y además en la nube
/// cuando hay backend y sesión.
///
/// Sin sesión no es un fallo: es el modo en que Lira funciona sin cuenta y sin
/// red. El estudiante lee y su avance se guarda igual, sólo que no viaja.
@Riverpod(keepAlive: true)
ReadingProgressRepository readingProgressRepository(Ref ref) {
  final local = LocalReadingProgressRepository(
    ref.watch(keyValueStoreProvider),
  );

  if (!AppConfig.hasRemoteBackend || !haySesion) return local;

  return SyncedReadingProgressRepository(
    local,
    SupabaseReadingProgressRepository(ref.watch(supabaseClientProvider)),
  );
}
