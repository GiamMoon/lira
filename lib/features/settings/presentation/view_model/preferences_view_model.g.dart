// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Preferencias de la app, recordadas entre sesiones.
///
/// `keepAlive` porque el tema lo consulta la raíz del árbol: si se reconstruye
/// al entrar y salir de Ajustes, la app parpadea entero.

@ProviderFor(Preferences)
final preferencesProvider = PreferencesProvider._();

/// Preferencias de la app, recordadas entre sesiones.
///
/// `keepAlive` porque el tema lo consulta la raíz del árbol: si se reconstruye
/// al entrar y salir de Ajustes, la app parpadea entero.
final class PreferencesProvider
    extends $NotifierProvider<Preferences, AppPreferences> {
  /// Preferencias de la app, recordadas entre sesiones.
  ///
  /// `keepAlive` porque el tema lo consulta la raíz del árbol: si se reconstruye
  /// al entrar y salir de Ajustes, la app parpadea entero.
  PreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesHash();

  @$internal
  @override
  Preferences create() => Preferences();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppPreferences>(value),
    );
  }
}

String _$preferencesHash() => r'f71ead3810449e308c8dec4c894829a09b79e5fd';

/// Preferencias de la app, recordadas entre sesiones.
///
/// `keepAlive` porque el tema lo consulta la raíz del árbol: si se reconstruye
/// al entrar y salir de Ajustes, la app parpadea entero.

abstract class _$Preferences extends $Notifier<AppPreferences> {
  AppPreferences build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppPreferences, AppPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppPreferences, AppPreferences>,
              AppPreferences,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
