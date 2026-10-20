/// Destino inicial que decide el arranque de la app.
///
/// El dominio no conoce rutas ni `go_router`: expresa *intención*, y la capa de
/// presentación la traduce a navegación.
enum StartDestination { onboarding, library }
