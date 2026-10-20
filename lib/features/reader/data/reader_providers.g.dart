// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chapterRepository)
final chapterRepositoryProvider = ChapterRepositoryProvider._();

final class ChapterRepositoryProvider
    extends
        $FunctionalProvider<
          ChapterRepository,
          ChapterRepository,
          ChapterRepository
        >
    with $Provider<ChapterRepository> {
  ChapterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chapterRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chapterRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChapterRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChapterRepository create(Ref ref) {
    return chapterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChapterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChapterRepository>(value),
    );
  }
}

String _$chapterRepositoryHash() => r'337db3eadbacc441c3d7541d27fa61f90f1ecb5a';

@ProviderFor(activityRepository)
final activityRepositoryProvider = ActivityRepositoryProvider._();

final class ActivityRepositoryProvider
    extends
        $FunctionalProvider<
          ActivityRepository,
          ActivityRepository,
          ActivityRepository
        >
    with $Provider<ActivityRepository> {
  ActivityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityRepositoryHash();

  @$internal
  @override
  $ProviderElement<ActivityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ActivityRepository create(Ref ref) {
    return activityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityRepository>(value),
    );
  }
}

String _$activityRepositoryHash() =>
    r'56bda0f8775b23c87fe27185373fc97d168f4aad';

/// Las creaciones se guardan siempre en el dispositivo, y además en la nube
/// cuando hay sesión.
///
/// Siguen siendo privadas: la tabla está protegida por RLS contra
/// `auth.uid()`, así que nadie más las ve. Sincronizarlas sólo sirve para que
/// no se pierdan al cambiar de teléfono.

@ProviderFor(activityResponseRepository)
final activityResponseRepositoryProvider =
    ActivityResponseRepositoryProvider._();

/// Las creaciones se guardan siempre en el dispositivo, y además en la nube
/// cuando hay sesión.
///
/// Siguen siendo privadas: la tabla está protegida por RLS contra
/// `auth.uid()`, así que nadie más las ve. Sincronizarlas sólo sirve para que
/// no se pierdan al cambiar de teléfono.

final class ActivityResponseRepositoryProvider
    extends
        $FunctionalProvider<
          ActivityResponseRepository,
          ActivityResponseRepository,
          ActivityResponseRepository
        >
    with $Provider<ActivityResponseRepository> {
  /// Las creaciones se guardan siempre en el dispositivo, y además en la nube
  /// cuando hay sesión.
  ///
  /// Siguen siendo privadas: la tabla está protegida por RLS contra
  /// `auth.uid()`, así que nadie más las ve. Sincronizarlas sólo sirve para que
  /// no se pierdan al cambiar de teléfono.
  ActivityResponseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityResponseRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityResponseRepositoryHash();

  @$internal
  @override
  $ProviderElement<ActivityResponseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ActivityResponseRepository create(Ref ref) {
    return activityResponseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityResponseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityResponseRepository>(value),
    );
  }
}

String _$activityResponseRepositoryHash() =>
    r'c5f211339cd27bbfbf571d2bb5f8de5438f96965';
