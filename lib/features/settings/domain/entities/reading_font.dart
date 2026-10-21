import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

/// Con qué letra se lee.
///
/// No es un capricho decorativo: la forma de la letra cambia cuánto aguanta
/// leyendo alguien a quien le cuesta. Por eso las tres opciones son distintas
/// de verdad —una serif de libro, una sans de pantalla y una diseñada para
/// baja visión— y no tres variantes del mismo gris.
enum ReadingFont {
  serif('Libro', 'Serif clásica, como una novela impresa.'),
  sans('Pantalla', 'Sans limpia, cómoda en móviles pequeños.'),
  legible(
    'Máxima claridad',
    'Diseñada para leer con poca vista: cada letra se distingue de las demás.',
  );

  const ReadingFont(this.label, this.description);

  final String label;
  final String description;

  /// El estilo de lectura de esta tipografía. Las medidas las fija el tema:
  /// aquí sólo se elige cuál de las tres.
  TextStyle style(Color color) => switch (this) {
    ReadingFont.serif => AppTypography.readingSerif(color),
    ReadingFont.sans => AppTypography.readingSans(color),
    ReadingFont.legible => AppTypography.readingLegible(color),
  };

  /// Muestra corta para la pantalla de ajustes.
  static const String sample = 'Era el mejor de los tiempos.';
}
