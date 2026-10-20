import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografía de Lira.
///
/// Pareja tipográfica:
/// - **Fraunces** (serif de contraste alto) para títulos y la voz editorial.
///   Da el aire de libro sin sentirse acartonado.
/// - **Plus Jakarta Sans** para interfaz y cuerpo: geométrica, joven, legible
///   en pantallas pequeñas.
///
/// TODO(assets): empaquetar los .ttf en `assets/fonts/` para que la primera
/// ejecución no dependa de red (google_fonts descarga y cachea en runtime).
abstract final class AppTypography {
  static TextTheme textTheme(Color onSurface, Color muted) {
    final display = GoogleFonts.fraunces(color: onSurface);
    final body = GoogleFonts.plusJakartaSans(color: onSurface);

    return TextTheme(
      displayLarge: display.copyWith(
        fontSize: 44,
        height: 1.05,
        fontWeight: FontWeight.w600,
        letterSpacing: -1,
      ),
      displayMedium: display.copyWith(
        fontSize: 34,
        height: 1.1,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
      ),
      headlineMedium: display.copyWith(
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: body.copyWith(
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: body.copyWith(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: body.copyWith(fontSize: 16, height: 1.55),
      bodyMedium: body.copyWith(fontSize: 14, height: 1.5, color: muted),
      labelLarge: body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelSmall: body.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: muted,
      ),
    );
  }

  /// Estilo reservado para el lector: serif, cómodo, medida larga.
  ///
  /// Es el que se usa cuando nadie ha elegido otra cosa. Las tres familias de
  /// lectura viven aquí, en el tema; cuál de ellas se aplica lo decide la
  /// preferencia del estudiante (`ReadingFont`).
  static TextStyle reading(Color color) => readingSerif(color);

  /// Serif de libro. El aire de una novela impresa.
  static TextStyle readingSerif(Color color) => GoogleFonts.fraunces(
    color: color,
    fontSize: 19,
    height: 1.75,
    fontWeight: FontWeight.w400,
  );

  /// Sans de pantalla: más estrecha, rinde mejor en móviles pequeños.
  static TextStyle readingSans(Color color) => GoogleFonts.plusJakartaSans(
    color: color,
    fontSize: 17.5,
    height: 1.7,
    fontWeight: FontWeight.w400,
  );

  /// Atkinson Hyperlegible, diseñada para baja visión: cada letra se
  /// distingue de la que se le parece (l/I/1, O/0). Pide más interlineado
  /// porque tiene el ojo mucho mayor que una serif.
  static TextStyle readingLegible(Color color) =>
      GoogleFonts.atkinsonHyperlegible(
        color: color,
        fontSize: 18,
        height: 1.8,
        fontWeight: FontWeight.w400,
      );
}
