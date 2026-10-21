// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReaderViewModel)
final readerViewModelProvider = ReaderViewModelFamily._();

final class ReaderViewModelProvider
    extends $AsyncNotifierProvider<ReaderViewModel, ReaderState> {
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

String _$readerViewModelHash() => r'd2a1f573eae76a92c4c96ec5204a3db39d1d1d66';

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

  ReaderViewModelProvider call(String bookId) =>
      ReaderViewModelProvider._(argument: bookId, from: this);

  @override
  String toString() => r'readerViewModelProvider';
}

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
