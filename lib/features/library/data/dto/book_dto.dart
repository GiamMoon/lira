import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/book.dart';

part 'book_dto.g.dart';

/// Representación de transporte de una obra (fila de Supabase / JSON).
///
/// Vive aparte de [Book] a propósito: si mañana cambia una columna, cambia el
/// DTO y su mapeo, no el dominio ni la UI.
@JsonSerializable(fieldRename: FieldRename.snake)
class BookDto {
  const BookDto({
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

  factory BookDto.fromJson(Map<String, dynamic> json) =>
      _$BookDtoFromJson(json);

  final String id;
  final String title;
  final String author;
  final String synopsis;
  final String category;
  final int chapterCount;
  final int minutesToRead;
  final String? coverUrl;

  /// La columna es `not null default '{}'`, así que el valor por defecto del
  /// constructor basta: no hace falta duplicarlo en `@JsonKey`.
  final List<String> tags;

  Map<String, dynamic> toJson() => _$BookDtoToJson(this);

  Book toDomain() => Book(
    id: id,
    title: title,
    author: author,
    synopsis: synopsis,
    category: BookCategory.fromName(category),
    chapterCount: chapterCount,
    minutesToRead: minutesToRead,
    coverUrl: coverUrl,
    tags: tags,
  );
}
