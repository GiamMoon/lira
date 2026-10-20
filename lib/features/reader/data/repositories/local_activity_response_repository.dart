import 'dart:convert';

import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/activity_response.dart';
import '../../domain/repositories/activity_response_repository.dart';

/// Las creaciones se guardan en el dispositivo.
///
/// Es una decisión de producto: lo que un estudiante escribe en una dinámica
/// es suyo y no viaja a ningún sitio hasta que él decida compartirlo.
class LocalActivityResponseRepository implements ActivityResponseRepository {
  const LocalActivityResponseRepository(this._store);

  final KeyValueStore _store;

  @override
  Future<List<ActivityResponse>> fetchAll() async {
    final entries = _read();

    return entries.entries
        .map(
          (entry) => ActivityResponse(
            activityId: entry.key,
            content: (entry.value['content'] as String?) ?? '',
            createdAt:
                DateTime.tryParse((entry.value['created_at'] as String?) ?? '') ??
                DateTime.now(),
            isShared: (entry.value['is_shared'] as bool?) ?? false,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> save(ActivityResponse response) async {
    final entries = _read()
      ..[response.activityId] = <String, dynamic>{
        'content': response.content,
        'created_at': response.createdAt.toIso8601String(),
        'is_shared': response.isShared,
      };

    await _store.writeString(
      StorageKeys.activityResponses,
      jsonEncode(entries),
    );
  }

  Map<String, Map<String, dynamic>> _read() {
    final raw = _store.readString(StorageKeys.activityResponses);
    if (raw == null || raw.isEmpty) return <String, Map<String, dynamic>>{};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
      );
    } on FormatException {
      return <String, Map<String, dynamic>>{};
    }
  }
}
