// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookDto _$BookDtoFromJson(Map<String, dynamic> json) => BookDto(
  id: json['id'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  synopsis: json['synopsis'] as String,
  category: json['category'] as String,
  chapterCount: (json['chapter_count'] as num).toInt(),
  minutesToRead: (json['minutes_to_read'] as num).toInt(),
  coverUrl: json['cover_url'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$BookDtoToJson(BookDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'author': instance.author,
  'synopsis': instance.synopsis,
  'category': instance.category,
  'chapter_count': instance.chapterCount,
  'minutes_to_read': instance.minutesToRead,
  'cover_url': instance.coverUrl,
  'tags': instance.tags,
};
