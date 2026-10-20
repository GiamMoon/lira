// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_progress_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingProgressDto _$ReadingProgressDtoFromJson(Map<String, dynamic> json) =>
    ReadingProgressDto(
      bookId: json['book_id'] as String,
      chaptersRead: (json['chapters_read'] as num).toInt(),
      chapterCount: (json['chapter_count'] as num).toInt(),
      status: json['status'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$ReadingProgressDtoToJson(ReadingProgressDto instance) =>
    <String, dynamic>{
      'book_id': instance.bookId,
      'chapters_read': instance.chaptersRead,
      'chapter_count': instance.chapterCount,
      'status': instance.status,
      'updated_at': instance.updatedAt,
    };
