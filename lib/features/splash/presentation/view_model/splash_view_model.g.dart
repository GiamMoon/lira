// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel del splash (capa de presentación en MVVM).
///
/// No conoce widgets: expone un [SplashState] y dos comandos. La vista
/// observa el estado y decide cómo se ve; el ViewModel decide qué pasa.

@ProviderFor(SplashViewModel)
final splashViewModelProvider = SplashViewModelProvider._();

/// ViewModel del splash (capa de presentación en MVVM).
///
/// No conoce widgets: expone un [SplashState] y dos comandos. La vista
/// observa el estado y decide cómo se ve; el ViewModel decide qué pasa.
final class SplashViewModelProvider
    extends $NotifierProvider<SplashViewModel, SplashState> {
  /// ViewModel del splash (capa de presentación en MVVM).
  ///
  /// No conoce widgets: expone un [SplashState] y dos comandos. La vista
  /// observa el estado y decide cómo se ve; el ViewModel decide qué pasa.
  SplashViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashViewModelHash();

  @$internal
  @override
  SplashViewModel create() => SplashViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplashState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplashState>(value),
    );
  }
}

String _$splashViewModelHash() => r'c8fc134e44d36d7ce40581668f62f89ecb4e70fc';

/// ViewModel del splash (capa de presentación en MVVM).
///
/// No conoce widgets: expone un [SplashState] y dos comandos. La vista
/// observa el estado y decide cómo se ve; el ViewModel decide qué pasa.

abstract class _$SplashViewModel extends $Notifier<SplashState> {
  SplashState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SplashState, SplashState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SplashState, SplashState>,
              SplashState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
