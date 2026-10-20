import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/storage/key_value_store.dart';
import '../domain/app_bootstrapper.dart';
import '../domain/start_destination.dart';

part 'default_app_bootstrapper.g.dart';

/// Implementación por defecto del arranque.
///
/// Hoy sólo resuelve si el estudiante ya pasó por el onboarding. A medida que
/// Lira crezca, aquí entran: restaurar sesión, precargar el catálogo desde
/// caché y disparar la sincronización en segundo plano.
class DefaultAppBootstrapper implements AppBootstrapper {
  const DefaultAppBootstrapper(this._store);

  final KeyValueStore _store;

  @override
  Future<StartDestination> run() async {
    final completedOnboarding =
        _store.readBool(StorageKeys.onboardingCompleted) ?? false;

    return completedOnboarding
        ? StartDestination.library
        : StartDestination.onboarding;
  }
}

@riverpod
AppBootstrapper appBootstrapper(Ref ref) =>
    DefaultAppBootstrapper(ref.watch(keyValueStoreProvider));
