// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creations_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reúne lo que el estudiante ha escrito y lo que lleva leído.
///
/// Las respuestas sólo guardan el id de la dinámica, así que aquí se cruzan
/// con el catálogo para poder enseñar la consigna y de qué libro salió. Se
/// hace al vuelo y no se duplica el texto de la consigna en cada respuesta:
/// si un profesor la reescribe, la creación sigue colgando de la buena.

@ProviderFor(CreationsViewModel)
final creationsViewModelProvider = CreationsViewModelProvider._();

/// Reúne lo que el estudiante ha escrito y lo que lleva leído.
///
/// Las respuestas sólo guardan el id de la dinámica, así que aquí se cruzan
/// con el catálogo para poder enseñar la consigna y de qué libro salió. Se
/// hace al vuelo y no se duplica el texto de la consigna en cada respuesta:
/// si un profesor la reescribe, la creación sigue colgando de la buena.
final class CreationsViewModelProvider
    extends $AsyncNotifierProvider<CreationsViewModel, CreationsState> {
  /// Reúne lo que el estudiante ha escrito y lo que lleva leído.
  ///
  /// Las respuestas sólo guardan el id de la dinámica, así que aquí se cruzan
  /// con el catálogo para poder enseñar la consigna y de qué libro salió. Se
  /// hace al vuelo y no se duplica el texto de la consigna en cada respuesta:
  /// si un profesor la reescribe, la creación sigue colgando de la buena.
  CreationsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creationsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creationsViewModelHash();

  @$internal
  @override
  CreationsViewModel create() => CreationsViewModel();
}

String _$creationsViewModelHash() =>
    r'e2815c132099db9408acea33311751912b783875';

/// Reúne lo que el estudiante ha escrito y lo que lleva leído.
///
/// Las respuestas sólo guardan el id de la dinámica, así que aquí se cruzan
/// con el catálogo para poder enseñar la consigna y de qué libro salió. Se
/// hace al vuelo y no se duplica el texto de la consigna en cada respuesta:
/// si un profesor la reescribe, la creación sigue colgando de la buena.

abstract class _$CreationsViewModel extends $AsyncNotifier<CreationsState> {
  FutureOr<CreationsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CreationsState>, CreationsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CreationsState>, CreationsState>,
              AsyncValue<CreationsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
