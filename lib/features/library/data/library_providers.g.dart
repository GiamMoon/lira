// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Elige el origen del catálogo según la configuración de entorno.
///
/// Este `if` es el único sitio de toda la app que sabe si hay backend: el
/// ViewModel, la vista y los tests hablan siempre con [BookRepository].

@ProviderFor(bookRepository)
final bookRepositoryProvider = BookRepositoryProvider._();

/// Elige el origen del catálogo según la configuración de entorno.
///
/// Este `if` es el único sitio de toda la app que sabe si hay backend: el
/// ViewModel, la vista y los tests hablan siempre con [BookRepository].

final class BookRepositoryProvider
    extends $FunctionalProvider<BookRepository, BookRepository, BookRepository>
    with $Provider<BookRepository> {
  /// Elige el origen del catálogo según la configuración de entorno.
  ///
  /// Este `if` es el único sitio de toda la app que sabe si hay backend: el
  /// ViewModel, la vista y los tests hablan siempre con [BookRepository].
  BookRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BookRepository create(Ref ref) {
    return bookRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookRepository>(value),
    );
  }
}

String _$bookRepositoryHash() => r'a21d8aaeb42cf09fd155b4ec75a8b3bac19a19db';

/// El progreso se guarda siempre en el dispositivo, y además en la nube
/// cuando hay backend y sesión.
///
/// Sin sesión no es un fallo: es el modo en que Lira funciona sin cuenta y sin
/// red. El estudiante lee y su avance se guarda igual, sólo que no viaja.

@ProviderFor(readingProgressRepository)
final readingProgressRepositoryProvider = ReadingProgressRepositoryProvider._();

/// El progreso se guarda siempre en el dispositivo, y además en la nube
/// cuando hay backend y sesión.
///
/// Sin sesión no es un fallo: es el modo en que Lira funciona sin cuenta y sin
/// red. El estudiante lee y su avance se guarda igual, sólo que no viaja.

final class ReadingProgressRepositoryProvider
    extends
        $FunctionalProvider<
          ReadingProgressRepository,
          ReadingProgressRepository,
          ReadingProgressRepository
        >
    with $Provider<ReadingProgressRepository> {
  /// El progreso se guarda siempre en el dispositivo, y además en la nube
  /// cuando hay backend y sesión.
  ///
  /// Sin sesión no es un fallo: es el modo en que Lira funciona sin cuenta y sin
  /// red. El estudiante lee y su avance se guarda igual, sólo que no viaja.
  ReadingProgressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingProgressRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingProgressRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReadingProgressRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingProgressRepository create(Ref ref) {
    return readingProgressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingProgressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingProgressRepository>(value),
    );
  }
}

String _$readingProgressRepositoryHash() =>
    r'86a54e2b7822f67ccf58fb05afe84a5d54bc4310';
