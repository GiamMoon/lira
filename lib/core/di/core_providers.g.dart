// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Punto de inyección de `SharedPreferences`.
///
/// Se resuelve en `main()` con `overrideWithValue`, de modo que el árbol de
/// widgets nunca espera un `Future` y los tests pueden inyectar un doble.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Punto de inyección de `SharedPreferences`.
///
/// Se resuelve en `main()` con `overrideWithValue`, de modo que el árbol de
/// widgets nunca espera un `Future` y los tests pueden inyectar un doble.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Punto de inyección de `SharedPreferences`.
  ///
  /// Se resuelve en `main()` con `overrideWithValue`, de modo que el árbol de
  /// widgets nunca espera un `Future` y los tests pueden inyectar un doble.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'3d9b62021cd3e10324e508a4801de79f16fdcd13';

@ProviderFor(keyValueStore)
final keyValueStoreProvider = KeyValueStoreProvider._();

final class KeyValueStoreProvider
    extends $FunctionalProvider<KeyValueStore, KeyValueStore, KeyValueStore>
    with $Provider<KeyValueStore> {
  KeyValueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyValueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyValueStoreHash();

  @$internal
  @override
  $ProviderElement<KeyValueStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KeyValueStore create(Ref ref) {
    return keyValueStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KeyValueStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KeyValueStore>(value),
    );
  }
}

String _$keyValueStoreHash() => r'2c77909f6432c03581fee4b71a99f840c12d04db';
