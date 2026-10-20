import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../data/default_app_bootstrapper.dart';
import 'splash_state.dart';

part 'splash_view_model.g.dart';

/// ViewModel del splash (capa de presentación en MVVM).
///
/// No conoce widgets: expone un [SplashState] y dos comandos. La vista
/// observa el estado y decide cómo se ve; el ViewModel decide qué pasa.
@riverpod
class SplashViewModel extends _$SplashViewModel {
  @override
  SplashState build() {
    // El arranque se dispara fuera del `build` para no mutar el estado
    // mientras se está construyendo.
    Future<void>.microtask(_bootstrap);
    return const SplashState.preparing();
  }

  Future<void> _bootstrap() async {
    if (!state.isPreparing) state = const SplashState.preparing();

    try {
      // El arranque real y el tiempo mínimo de marca corren en paralelo:
      // si el arranque es instantáneo, la animación igual se ve completa.
      final (destination, _) = await (
        ref.read(appBootstrapperProvider).run(),
        Future<void>.delayed(Motion.minimumSplash),
      ).wait;

      if (!ref.mounted) return;
      state = SplashState.ready(destination);
    } on Object catch (error, stackTrace) {
      developer.log(
        'Fallo el arranque de la app',
        name: 'SplashViewModel',
        error: error,
        stackTrace: stackTrace,
      );
      if (!ref.mounted) return;
      state = const SplashState.failed(
        'No pudimos preparar tu biblioteca. Revisa tu conexión.',
      );
    }
  }

  /// Comando de reintento tras un fallo de arranque.
  Future<void> retry() => _bootstrap();
}
