import '../../domain/entities/activity.dart';

/// DTO de una dinámica (`activities`).
class ActivityDto {
  const ActivityDto({
    required this.id,
    required this.bookId,
    required this.kind,
    required this.prompt,
    this.chapterId,
    this.hint,
  });

  factory ActivityDto.fromJson(Map<String, dynamic> json) => ActivityDto(
    id: json['id'] as String,
    bookId: json['book_id'] as String,
    chapterId: json['chapter_id'] as String?,
    kind: json['kind'] as String,
    prompt: json['prompt'] as String,
    hint: json['hint'] as String?,
  );

  final String id;
  final String bookId;
  final String? chapterId;
  final String kind;
  final String prompt;
  final String? hint;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'book_id': bookId,
    'chapter_id': chapterId,
    'kind': kind,
    'prompt': prompt,
    'hint': hint,
  };

  /// Una dinámica sin capítulo simplemente nunca se ofrece: se prefiere eso a
  /// mostrarla en un punto arbitrario de la obra.
  Activity toDomain() => Activity(
    id: id,
    bookId: bookId,
    chapterId: chapterId ?? '',
    kind: ActivityKind.fromStorage(kind),
    prompt: prompt,
    hint: hint,
  );
}
