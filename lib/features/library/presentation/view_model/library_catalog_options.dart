import '../../domain/entities/book.dart';

enum LibraryDisplayMode { covers, list }

enum LibrarySortOrder {
  title,
  author,
  duration;

  List<Book> sorted(Iterable<Book> books) => books.toList()..sort(_compare);

  int _compare(Book first, Book second) => switch (this) {
    title => first.title.toLowerCase().compareTo(second.title.toLowerCase()),
    author => first.author.toLowerCase().compareTo(second.author.toLowerCase()),
    duration => first.minutesToRead.compareTo(second.minutesToRead),
  };
}
