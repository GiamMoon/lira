import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/network/supabase_providers.dart';
import '../../../core/network/supabase_session.dart';
import '../domain/repositories/activity_repository.dart';
import '../domain/repositories/activity_response_repository.dart';
import '../domain/repositories/chapter_repository.dart';
import 'repositories/local_activity_response_repository.dart';
import 'repositories/seed_activity_repository.dart';
import 'repositories/seed_chapter_repository.dart';
import 'repositories/supabase_activity_repository.dart';
import 'repositories/supabase_activity_response_repository.dart';
import 'repositories/supabase_chapter_repository.dart';
import 'repositories/synced_activity_response_repository.dart';

part 'reader_providers.g.dart';

@Riverpod(keepAlive: true)
ChapterRepository chapterRepository(Ref ref) => AppConfig.hasRemoteBackend
    ? SupabaseChapterRepository(ref.watch(supabaseClientProvider))
    : const SeedChapterRepository();

@Riverpod(keepAlive: true)
ActivityRepository activityRepository(Ref ref) => AppConfig.hasRemoteBackend
    ? SupabaseActivityRepository(ref.watch(supabaseClientProvider))
    : const SeedActivityRepository();

/// Las creaciones se guardan siempre en el dispositivo, y además en la nube
/// cuando hay sesión.
///
/// Siguen siendo privadas: la tabla está protegida por RLS contra
/// `auth.uid()`, así que nadie más las ve. Sincronizarlas sólo sirve para que
/// no se pierdan al cambiar de teléfono.
@Riverpod(keepAlive: true)
ActivityResponseRepository activityResponseRepository(Ref ref) {
  final local = LocalActivityResponseRepository(
    ref.watch(keyValueStoreProvider),
  );

  if (!AppConfig.hasRemoteBackend || !haySesion) return local;

  return SyncedActivityResponseRepository(
    local,
    SupabaseActivityResponseRepository(ref.watch(supabaseClientProvider)),
  );
}
