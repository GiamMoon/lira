/// Configuración de entorno, inyectada en tiempo de compilación.
///
/// Las credenciales nunca se escriben en el código ni se suben al repo. Se
/// pasan al compilar:
///
/// ```sh
/// flutter run --dart-define-from-file=env.json
/// ```
///
/// Copia `env.example.json` a `env.json` (ignorado por git) y rellena los
/// valores del panel de Supabase → Project Settings → API.
///
/// Si no hay credenciales, Lira arranca igual contra el catálogo semilla
/// local: el desarrollo y las demos nunca dependen de tener backend.
abstract final class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Clave publicable actual (`sb_publishable_…`).
  static const String _publishableKey = String.fromEnvironment('SUPABASE_KEY');

  /// Clave `anon` heredada, por si el proyecto es anterior al cambio de
  /// nomenclatura de Supabase. Ambas viajan igual: como cabecera `apikey`.
  static const String _legacyAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static String get supabaseKey =>
      _publishableKey.isNotEmpty ? _publishableKey : _legacyAnonKey;

  /// Hay backend configurado y podemos hablar con la nube.
  static bool get hasRemoteBackend =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
