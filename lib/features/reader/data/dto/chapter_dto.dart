import '../../domain/entities/chapter.dart';
import '../../domain/entities/content_block.dart';

/// DTO de un capítulo.
///
/// Está escrito a mano —y no con `json_serializable` como el resto— porque
/// `body` es una lista **polimórfica** de bloques: el generador tendría que
/// pelearse con un converter para algo que aquí son cuatro líneas.
class ChapterDto {
  const ChapterDto({
    required this.id,
    required this.bookId,
    required this.position,
    required this.title,
    required this.body,
  });

  factory ChapterDto.fromJson(Map<String, dynamic> json) => ChapterDto(
    id: json['id'] as String,
    bookId: json['book_id'] as String,
    position: (json['position'] as num?)?.toInt() ?? 0,
    title: (json['title'] as String?) ?? '',
    body: (json['body'] as List<dynamic>? ?? const <dynamic>[])
        .map((block) => Map<String, dynamic>.from(block as Map))
        .toList(growable: false),
  );

  final String id;
  final String bookId;
  final int position;
  final String title;
  final List<Map<String, dynamic>> body;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'book_id': bookId,
    'position': position,
    'title': title,
    'body': body,
  };

  Chapter toDomain() => Chapter(
    id: id,
    bookId: bookId,
    position: position,
    title: title,
    blocks: body.map(ContentBlock.fromJson).toList(growable: false),
  );
}
