// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel de la biblioteca.
///
/// Carga catálogo y progreso, y expone comandos de intención: filtrar, buscar,
/// empezar y dejar un libro. La vista no toca repositorios.

@ProviderFor(LibraryViewModel)
final libraryViewModelProvider = LibraryViewModelProvider._();

/// ViewModel de la biblioteca.
///
/// Carga catálogo y progreso, y expone comandos de intención: filtrar, buscar,
/// empezar y dejar un libro. La vista no toca repositorios.
final class LibraryViewModelProvider
    extends $AsyncNotifierProvider<LibraryViewModel, LibraryState> {
  /// ViewModel de la biblioteca.
  ///
  /// Carga catálogo y progreso, y expone comandos de intención: filtrar, buscar,
  /// empezar y dejar un libro. La vista no toca repositorios.
  LibraryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryViewModelHash();

  @$internal
  @override
  LibraryViewModel create() => LibraryViewModel();
}

String _$libraryViewModelHash() => r'd241fb5ed8cefae6c3bbbdac01d3d012177255d9';

/// ViewModel de la biblioteca.
///
/// Carga catálogo y progreso, y expone comandos de intención: filtrar, buscar,
/// empezar y dejar un libro. La vista no toca repositorios.

abstract class _$LibraryViewModel extends $AsyncNotifier<LibraryState> {
  FutureOr<LibraryState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LibraryState>, LibraryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LibraryState>, LibraryState>,
              AsyncValue<LibraryState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
