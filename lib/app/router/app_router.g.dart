// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Router de la app.
///
/// Se expone como provider para que dependencias futuras (sesión, feature
/// flags) puedan participar en `redirect` sin globales.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Router de la app.
///
/// Se expone como provider para que dependencias futuras (sesión, feature
/// flags) puedan participar en `redirect` sin globales.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Router de la app.
  ///
  /// Se expone como provider para que dependencias futuras (sesión, feature
  /// flags) puedan participar en `redirect` sin globales.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'911ac22659897975d906b03e3e89a1ee6f8cddae';
