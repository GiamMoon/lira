import '../../domain/entities/book.dart';

/// Catálogo de respaldo de Lira.
///
/// Sólo se usa cuando no hay credenciales de Supabase (`env.json`). Contiene
/// los mismos libros que el catálogo real para que el modo sin conexión no
/// enseñe una biblioteca distinta a la de producción.
abstract final class BookSeed {
  static const List<Book> catalog = <Book>[
    Book(
      id: 'las-aventuras-de-tom-sawyer',
      title: 'Las aventuras de Tom Sawyer',
      author: 'Mark Twain',
      synopsis:
          'Tom convence a medio pueblo de que pintar una valla es un '
          'privilegio. Luego ve un asesinato, se escapa a una isla y aparece '
          'en su propio funeral.',
      category: BookCategory.novela,
      chapterCount: 96,
      minutesToRead: 351,
      tags: <String>['Clásico', 'Aventura'],
    ),
    Book(
      id: 'john-wesley',
      title: 'John Wesley',
      author: 'Janet y Geoff Benge',
      synopsis:
          'Lo sacaron de una casa en llamas a los cinco años. Después '
          'recorrió 400.000 kilómetros a caballo predicando, y lo echaron de '
          'más iglesias de las que puedes contar.',
      category: BookCategory.biografia,
      chapterCount: 49,
      minutesToRead: 195,
      tags: <String>['Biografía', 'Fe', 'Historia'],
    ),
    Book(
      id: 'el-camino-de-sherlock',
      title: 'El camino de Sherlock',
      author: 'Andrea Ferrari',
      synopsis:
          'Tiene un cociente intelectual de 152 y en su casa ya hablan del '
          'Nobel. Él solo quiere que lo dejen en paz, hasta que unos '
          'asesinatos recientes le dan algo en qué pensar de verdad.',
      category: BookCategory.novela,
      chapterCount: 40,
      minutesToRead: 145,
      tags: <String>['Misterio', 'Juvenil'],
    ),
  ];
}
