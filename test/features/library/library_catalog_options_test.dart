import 'package:flutter_test/flutter_test.dart';
import 'package:lira/features/library/domain/entities/book.dart';
import 'package:lira/features/library/presentation/view_model/library_catalog_options.dart';

Book _book(String title, String author, int minutes) => Book(
  id: title,
  title: title,
  author: author,
  synopsis: '',
  category: BookCategory.cuento,
  chapterCount: 1,
  minutesToRead: minutes,
);

void main() {
  final books = [
    _book('Zorro', 'Borges', 5),
    _book('agua', 'Cervantes', 30),
    _book('Brisa', 'Arguedas', 15),
  ];

  test(
    'ordena por título sin distinguir mayúsculas ni modificar el origen',
    () {
      final originalOrder = [...books];
      final sorted = LibrarySortOrder.title.sorted(books);

      expect(sorted.map((book) => book.title), ['agua', 'Brisa', 'Zorro']);
      expect(books, originalOrder);
    },
  );

  test('ordena por autor independientemente del título', () {
    final sorted = LibrarySortOrder.author.sorted(books);

    expect(sorted.map((book) => book.author), [
      'Arguedas',
      'Borges',
      'Cervantes',
    ]);
  });

  test('ordena primero las obras de menor duración', () {
    final sorted = LibrarySortOrder.duration.sorted(books);

    expect(sorted.map((book) => book.minutesToRead), [5, 15, 30]);
  });

  test('acepta un catálogo vacío con cualquier criterio', () {
    for (final order in LibrarySortOrder.values) {
      expect(order.sorted(const []), isEmpty);
    }
  });
}
