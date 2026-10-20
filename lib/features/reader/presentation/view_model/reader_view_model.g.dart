// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel del lector, uno por obra abierta.
///
/// Reglas de producto que se cumplen aquí, no en la UI:
/// - el avance se guarda solo, sin botón de "guardar";
/// - dejar un libro conserva el progreso;
/// - responder una dinámica es siempre opcional y nunca bloquea la lectura.

@ProviderFor(ReaderViewModel)
final readerViewModelProvider = ReaderViewModelFamily._();

/// ViewModel del lector, uno por obra abierta.
///
/// Reglas de producto que se cumplen aquí, no en la UI:
/// - el avance se guarda solo, sin botón de "guardar";
/// - dejar un libro conserva el progreso;
/// - responder una dinámica es siempre opcional y nunca bloquea la lectura.
final class ReaderViewModelProvider
    extends $AsyncNotifierProvider<ReaderViewModel, ReaderState> {
  /// ViewModel del lector, uno por obra abierta.
  ///
  /// Reglas de producto que se cumplen aquí, no en la UI:
  /// - el avance se guarda solo, sin botón de "guardar";
  /// - dejar un libro conserva el progreso;
  /// - responder una dinámica es siempre opcional y nunca bloquea la lectura.
  ReaderViewModelProvider._({
    required ReaderViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'readerViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readerViewModelHash();

  @override
  String toString() {
    return r'readerViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ReaderViewModel create() => ReaderViewModel();

  @override
  bool operator ==(Object other) {
    return other is ReaderViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readerViewModelHash() => r'a8b4264f8718730fdde018eb436dfc9c9501e1fb';

/// ViewModel del lector, uno por obra abierta.
///
/// Reglas de producto que se cumplen aquí, no en la UI:
/// - el avance se guarda solo, sin botón de "guardar";
/// - dejar un libro conserva el progreso;
/// - responder una dinámica es siempre opcional y nunca bloquea la lectura.

final class ReaderViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ReaderViewModel,
          AsyncValue<ReaderState>,
          ReaderState,
          FutureOr<ReaderState>,
          String
        > {
  ReaderViewModelFamily._()
    : super(
        retry: null,
        name: r'readerViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ViewModel del lector, uno por obra abierta.
  ///
  /// Reglas de producto que se cumplen aquí, no en la UI:
  /// - el avance se guarda solo, sin botón de "guardar";
  /// - dejar un libro conserva el progreso;
  /// - responder una dinámica es siempre opcional y nunca bloquea la lectura.

  ReaderViewModelProvider call(String bookId) =>
      ReaderViewModelProvider._(argument: bookId, from: this);

  @override
  String toString() => r'readerViewModelProvider';
}

/// ViewModel del lector, uno por obra abierta.
///
/// Reglas de producto que se cumplen aquí, no en la UI:
/// - el avance se guarda solo, sin botón de "guardar";
/// - dejar un libro conserva el progreso;
/// - responder una dinámica es siempre opcional y nunca bloquea la lectura.

abstract class _$ReaderViewModel extends $AsyncNotifier<ReaderState> {
  late final _$args = ref.$arg as String;
  String get bookId => _$args;

  FutureOr<ReaderState> build(String bookId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ReaderState>, ReaderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReaderState>, ReaderState>,
              AsyncValue<ReaderState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
