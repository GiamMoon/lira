/// Configuración inyectada mediante --dart-define-from-file.
abstract final class AppConfig {
  static const bool requireRemoteBackend = bool.fromEnvironment(
    'REQUIRE_REMOTE_BACKEND',
  );

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String _publishableKey = String.fromEnvironment('SUPABASE_KEY');

  /// Compatibilidad con proyectos que utilizan SUPABASE_ANON_KEY.
  static const String _legacyAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static String get supabaseKey =>
      _publishableKey.isNotEmpty ? _publishableKey : _legacyAnonKey;

  static bool get hasRemoteBackend =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
