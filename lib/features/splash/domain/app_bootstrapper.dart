import 'start_destination.dart';

/// Trabajo de arranque de la app: todo lo que debe estar listo antes de
/// mostrar la primera pantalla real (sesión, preferencias, catálogo cacheado…).
///
/// Es una interfaz para que el splash pueda probarse con dobles y para que el
/// arranque crezca sin reescribir la pantalla.
abstract interface class AppBootstrapper {
  Future<StartDestination> run();
}
