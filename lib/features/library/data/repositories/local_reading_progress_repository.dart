import 'dart:convert';

import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/reading_progress_repository.dart';
import '../dto/reading_progress_dto.dart';

/// Progreso guardado en el dispositivo.
///
/// Es local a propósito: el estudiante debe poder leer y conservar su avance
/// sin cuenta, sin datos y sin permiso de nadie. La sincronización con la nube
/// llegará encima de esto, no en su lugar.
class LocalReadingProgressRepository implements ReadingProgressRepository {
  const LocalReadingProgressRepository(this._store);

  final KeyValueStore _store;

  @override
  Future<List<ReadingProgress>> fetchAll() async {
    final entries = _read();
    return entries.values
        .map((json) => ReadingProgressDto.fromJson(json).toDomain())
        .toList(growable: false);
  }

  @override
  Future<void> save(ReadingProgress progress) async {
    final entries = _read()
      ..[progress.bookId] = ReadingProgressDto.fromDomain(progress).toJson();
    await _write(entries);
  }

  @override
  Future<void> remove(String bookId) async {
    final entries = _read()..remove(bookId);
    await _write(entries);
  }

  Map<String, Map<String, dynamic>> _read() {
    final raw = _store.readString(StorageKeys.readingProgress);
    if (raw == null || raw.isEmpty) return <String, Map<String, dynamic>>{};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
      );
    } on FormatException {
      // Dato corrupto: se descarta en silencio antes que romper la app.
      return <String, Map<String, dynamic>>{};
    }
  }

  Future<void> _write(Map<String, Map<String, dynamic>> entries) =>
      _store.writeString(StorageKeys.readingProgress, jsonEncode(entries));
}
