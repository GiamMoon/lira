import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/network/supabase_providers.dart';
import '../../../core/network/supabase_session.dart';
import '../domain/repositories/book_feedback_repository.dart';
import 'repositories/local_book_feedback_repository.dart';
import 'repositories/supabase_book_feedback_repository.dart';
import 'repositories/synced_book_feedback_repository.dart';

part 'closing_providers.g.dart';

/// La opinión de cierre se guarda siempre en el dispositivo, y además en la
/// nube cuando hay sesión.
///
/// Sigue siendo privada —las tablas están protegidas por RLS contra
/// `auth.uid()`— y sin sesión no se pierde nada: se queda en el móvil, que es
/// como funcionaba antes.
@Riverpod(keepAlive: true)
BookFeedbackRepository bookFeedbackRepository(Ref ref) {
  final local = LocalBookFeedbackRepository(ref.watch(keyValueStoreProvider));

  if (!AppConfig.hasRemoteBackend || !haySesion) return local;

  return SyncedBookFeedbackRepository(
    local,
    SupabaseBookFeedbackRepository(ref.watch(supabaseClientProvider)),
  );
}
