/// Rutas de Lira, tipadas.
///
/// Nadie escribe `'/biblioteca'` a mano: se navega con `AppRoute.library`.
enum AppRoute {
  splash('/', 'splash'),
  onboarding('/bienvenida', 'onboarding'),
  library('/biblioteca', 'biblioteca'),
  reader('/leer/:bookId', 'lector'),
  closing('/terminaste/:bookId', 'cierre'),
  creations('/tu-rincon', 'rincon'),
  settings('/ajustes', 'ajustes');

  const AppRoute(this.path, this.routeName);

  final String path;
  final String routeName;

  /// Nombre del parámetro de ruta de las pantallas de una obra.
  static const String bookIdParam = 'bookId';
}
