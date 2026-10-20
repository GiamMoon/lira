/// Contrato de almacenamiento clave-valor.
///
/// La capa de dominio depende de esta abstracción, no de `SharedPreferences`.
/// Mañana puede respaldarse en Hive, Isar o secure storage sin tocar features.
abstract interface class KeyValueStore {
  bool? readBool(String key);
  Future<void> writeBool(String key, {required bool value});

  String? readString(String key);
  Future<void> writeString(String key, String value);

  Future<void> remove(String key);
}

/// Claves de persistencia centralizadas: evita strings mágicos duplicados.
abstract final class StorageKeys {
  static const String onboardingCompleted = 'lira.onboarding_completed';
  static const String themeMode = 'lira.theme_mode';
  static const String readingProgress = 'lira.reading_progress';
  static const String activityResponses = 'lira.activity_responses';
  static const String readerTextSize = 'lira.reader_text_size';
  static const String readingFont = 'lira.reading_font';
  static const String studentName = 'lira.student_name';
  static const String bookFeedback = 'lira.book_feedback';
}
