// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'closing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// La opinión de cierre se guarda siempre en el dispositivo, y además en la
/// nube cuando hay sesión.
///
/// Sigue siendo privada —las tablas están protegidas por RLS contra
/// `auth.uid()`— y sin sesión no se pierde nada: se queda en el móvil, que es
/// como funcionaba antes.

@ProviderFor(bookFeedbackRepository)
final bookFeedbackRepositoryProvider = BookFeedbackRepositoryProvider._();

/// La opinión de cierre se guarda siempre en el dispositivo, y además en la
/// nube cuando hay sesión.
///
/// Sigue siendo privada —las tablas están protegidas por RLS contra
/// `auth.uid()`— y sin sesión no se pierde nada: se queda en el móvil, que es
/// como funcionaba antes.

final class BookFeedbackRepositoryProvider
    extends
        $FunctionalProvider<
          BookFeedbackRepository,
          BookFeedbackRepository,
          BookFeedbackRepository
        >
    with $Provider<BookFeedbackRepository> {
  /// La opinión de cierre se guarda siempre en el dispositivo, y además en la
  /// nube cuando hay sesión.
  ///
  /// Sigue siendo privada —las tablas están protegidas por RLS contra
  /// `auth.uid()`— y sin sesión no se pierde nada: se queda en el móvil, que es
  /// como funcionaba antes.
  BookFeedbackRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookFeedbackRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookFeedbackRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookFeedbackRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookFeedbackRepository create(Ref ref) {
    return bookFeedbackRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookFeedbackRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookFeedbackRepository>(value),
    );
  }
}

String _$bookFeedbackRepositoryHash() =>
    r'dc073e53490b05874c4b7751c116aef4c1dda84f';
