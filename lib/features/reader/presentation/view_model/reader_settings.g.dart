// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Preferencia de lectura, recordada entre sesiones.
///
/// Quien necesita letra grande la necesita **siempre**: tener que ajustarla en
/// cada libro sería una barrera, no una opción.

@ProviderFor(ReaderSettings)
final readerSettingsProvider = ReaderSettingsProvider._();

/// Preferencia de lectura, recordada entre sesiones.
///
/// Quien necesita letra grande la necesita **siempre**: tener que ajustarla en
/// cada libro sería una barrera, no una opción.
final class ReaderSettingsProvider
    extends $NotifierProvider<ReaderSettings, ReaderTextSize> {
  /// Preferencia de lectura, recordada entre sesiones.
  ///
  /// Quien necesita letra grande la necesita **siempre**: tener que ajustarla en
  /// cada libro sería una barrera, no una opción.
  ReaderSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerSettingsHash();

  @$internal
  @override
  ReaderSettings create() => ReaderSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReaderTextSize value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReaderTextSize>(value),
    );
  }
}

String _$readerSettingsHash() => r'24498a873429a91502197ebc169e63b67d7ec522';

/// Preferencia de lectura, recordada entre sesiones.
///
/// Quien necesita letra grande la necesita **siempre**: tener que ajustarla en
/// cada libro sería una barrera, no una opción.

abstract class _$ReaderSettings extends $Notifier<ReaderTextSize> {
  ReaderTextSize build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReaderTextSize, ReaderTextSize>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReaderTextSize, ReaderTextSize>,
              ReaderTextSize,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
