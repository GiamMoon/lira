import 'package:flutter/foundation.dart';

/// Forma literaria de una obra. Sirve para filtrar la estantería y para dar
/// expectativa de duración antes de abrir nada.
enum BookCategory {
  cuento('Cuento'),
  novela('Novela'),
  biografia('Biografía'),
  poesia('Poesía'),
  teatro('Teatro');

  const BookCategory(this.label);

  final String label;

  static BookCategory fromName(String value) => BookCategory.values.firstWhere(
    (category) => category.name == value,
    orElse: () => BookCategory.cuento,
  );
}

/// Una obra del catálogo de Lira.
///
/// Entidad de dominio: no sabe de Supabase, de JSON ni de widgets.
@immutable
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.synopsis,
    required this.category,
    required this.chapterCount,
    required this.minutesToRead,
    this.coverUrl,
    this.tags = const <String>[],
  });

  final String id;
  final String title;
  final String author;
  final String synopsis;
  final BookCategory category;
  final int chapterCount;

  /// Estimación de lectura completa. Se muestra siempre: saber que algo dura
  /// 12 minutos baja muchísimo la barrera de empezar.
  final int minutesToRead;

  /// Portada remota. Si es nula, Lira dibuja una portada generada.
  final String? coverUrl;
  final List<String> tags;

  bool get isShort => minutesToRead <= 20;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Book && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Book($id, $title)';
}
