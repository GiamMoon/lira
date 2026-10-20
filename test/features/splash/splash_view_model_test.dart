import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lira/core/theme/app_tokens.dart';
import 'package:lira/features/splash/data/default_app_bootstrapper.dart';
import 'package:lira/features/splash/domain/app_bootstrapper.dart';
import 'package:lira/features/splash/domain/start_destination.dart';
import 'package:lira/features/splash/presentation/view_model/splash_state.dart';
import 'package:lira/features/splash/presentation/view_model/splash_view_model.dart';

/// Doble de prueba: el ViewModel depende de la interfaz, no de la impl real,
/// así que el splash se puede probar sin `SharedPreferences` ni plugins.
class _FakeBootstrapper implements AppBootstrapper {
  _FakeBootstrapper(this._result);

  final StartDestination _result;

  @override
  Future<StartDestination> run() async => _result;
}

class _FailingBootstrapper implements AppBootstrapper {
  @override
  Future<StartDestination> run() async => throw StateError('sin red');
}

/// Contenedor con el arranque sustituido y una suscripción viva (sin ella,
/// Riverpod destruiría el provider antes de que termine el arranque).
ProviderContainer _containerWith(AppBootstrapper bootstrapper) {
  final container = ProviderContainer(
    overrides: [appBootstrapperProvider.overrideWithValue(bootstrapper)],
  );
  final subscription = container.listen(
    splashViewModelProvider,
    (_, _) {},
    fireImmediately: true,
  );
  addTearDown(subscription.close);
  addTearDown(container.dispose);
  return container;
}

/// Espera el tiempo mínimo de marca más un margen.
Future<void> _waitForBootstrap() =>
    Future<void>.delayed(Motion.minimumSplash + const Duration(milliseconds: 400));

void main() {
  group('SplashViewModel', () {
    test('empieza preparando', () {
      final container = _containerWith(
        _FakeBootstrapper(StartDestination.library),
      );

      expect(
        container.read(splashViewModelProvider),
        const SplashState.preparing(),
      );
    });

    test('resuelve el destino que decide el arranque', () async {
      final container = _containerWith(
        _FakeBootstrapper(StartDestination.onboarding),
      );

      await _waitForBootstrap();

      expect(
        container.read(splashViewModelProvider),
        const SplashState.ready(StartDestination.onboarding),
      );
    });

    test('respeta el tiempo mínimo de marca aunque el arranque sea instantáneo', () async {
      final container = _containerWith(
        _FakeBootstrapper(StartDestination.library),
      );

      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(container.read(splashViewModelProvider).isPreparing, isTrue);
    });

    test('expone un estado de fallo si el arranque revienta', () async {
      final container = _containerWith(_FailingBootstrapper());

      await _waitForBootstrap();

      expect(container.read(splashViewModelProvider).hasFailed, isTrue);
    });
  });
}
