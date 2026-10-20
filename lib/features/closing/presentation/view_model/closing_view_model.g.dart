// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'closing_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel del cierre de una obra.
///
/// Nada aquí valida ni exige: se puede guardar sin reacción, sin estrellas y
/// sin comentario. El único trabajo real es recordar lo que ya dijo, por si
/// vuelve a abrir la pantalla.

@ProviderFor(ClosingViewModel)
final closingViewModelProvider = ClosingViewModelFamily._();

/// ViewModel del cierre de una obra.
///
/// Nada aquí valida ni exige: se puede guardar sin reacción, sin estrellas y
/// sin comentario. El único trabajo real es recordar lo que ya dijo, por si
/// vuelve a abrir la pantalla.
final class ClosingViewModelProvider
    extends $AsyncNotifierProvider<ClosingViewModel, ClosingState> {
  /// ViewModel del cierre de una obra.
  ///
  /// Nada aquí valida ni exige: se puede guardar sin reacción, sin estrellas y
  /// sin comentario. El único trabajo real es recordar lo que ya dijo, por si
  /// vuelve a abrir la pantalla.
  ClosingViewModelProvider._({
    required ClosingViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'closingViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$closingViewModelHash();

  @override
  String toString() {
    return r'closingViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ClosingViewModel create() => ClosingViewModel();

  @override
  bool operator ==(Object other) {
    return other is ClosingViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$closingViewModelHash() => r'3d7db03204e6b37192e12bf997847deae9964c91';

/// ViewModel del cierre de una obra.
///
/// Nada aquí valida ni exige: se puede guardar sin reacción, sin estrellas y
/// sin comentario. El único trabajo real es recordar lo que ya dijo, por si
/// vuelve a abrir la pantalla.

final class ClosingViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ClosingViewModel,
          AsyncValue<ClosingState>,
          ClosingState,
          FutureOr<ClosingState>,
          String
        > {
  ClosingViewModelFamily._()
    : super(
        retry: null,
        name: r'closingViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ViewModel del cierre de una obra.
  ///
  /// Nada aquí valida ni exige: se puede guardar sin reacción, sin estrellas y
  /// sin comentario. El único trabajo real es recordar lo que ya dijo, por si
  /// vuelve a abrir la pantalla.

  ClosingViewModelProvider call(String bookId) =>
      ClosingViewModelProvider._(argument: bookId, from: this);

  @override
  String toString() => r'closingViewModelProvider';
}

/// ViewModel del cierre de una obra.
///
/// Nada aquí valida ni exige: se puede guardar sin reacción, sin estrellas y
/// sin comentario. El único trabajo real es recordar lo que ya dijo, por si
/// vuelve a abrir la pantalla.

abstract class _$ClosingViewModel extends $AsyncNotifier<ClosingState> {
  late final _$args = ref.$arg as String;
  String get bookId => _$args;

  FutureOr<ClosingState> build(String bookId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ClosingState>, ClosingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ClosingState>, ClosingState>,
              AsyncValue<ClosingState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
