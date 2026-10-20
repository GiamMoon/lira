// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_app_bootstrapper.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appBootstrapper)
final appBootstrapperProvider = AppBootstrapperProvider._();

final class AppBootstrapperProvider
    extends
        $FunctionalProvider<AppBootstrapper, AppBootstrapper, AppBootstrapper>
    with $Provider<AppBootstrapper> {
  AppBootstrapperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appBootstrapperProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appBootstrapperHash();

  @$internal
  @override
  $ProviderElement<AppBootstrapper> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppBootstrapper create(Ref ref) {
    return appBootstrapper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppBootstrapper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppBootstrapper>(value),
    );
  }
}

String _$appBootstrapperHash() => r'7776e30785f568da8fed3472470797f3e0c049e7';
