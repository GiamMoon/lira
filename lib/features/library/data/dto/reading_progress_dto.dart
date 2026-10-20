import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/reading_progress.dart';

part 'reading_progress_dto.g.dart';

/// Progreso serializable. Mismo formato en almacenamiento local y en la tabla
/// `reading_progress` de Supabase, para que sincronizar sea copiar.
@JsonSerializable(fieldRename: FieldRename.snake)
class ReadingProgressDto {
  const ReadingProgressDto({
    required this.bookId,
    required this.chaptersRead,
    required this.chapterCount,
    required this.status,
    required this.updatedAt,
  });

  factory ReadingProgressDto.fromJson(Map<String, dynamic> json) =>
      _$ReadingProgressDtoFromJson(json);

  factory ReadingProgressDto.fromDomain(ReadingProgress progress) =>
      ReadingProgressDto(
        bookId: progress.bookId,
        chaptersRead: progress.chaptersRead,
        chapterCount: progress.chapterCount,
        status: progress.status.name,
        updatedAt: progress.updatedAt.toIso8601String(),
      );

  final String bookId;
  final int chaptersRead;
  final int chapterCount;
  final String status;
  final String updatedAt;

  Map<String, dynamic> toJson() => _$ReadingProgressDtoToJson(this);

  ReadingProgress toDomain() => ReadingProgress(
    bookId: bookId,
    chaptersRead: chaptersRead,
    chapterCount: chapterCount,
    status: ReadingStatus.values.firstWhere(
      (value) => value.name == status,
      orElse: () => ReadingStatus.reading,
    ),
    updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
  );
}
