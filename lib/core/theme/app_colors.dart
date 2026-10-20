import 'package:flutter/material.dart';

/// Paleta de marca de Lira.
///
/// Fuente única de verdad del color. Ningún widget debería declarar un
/// `Color(0x...)` propio: si un tono no existe aquí, se agrega aquí.
abstract final class AppColors {
  // — Identidad ————————————————————————————————————————————————
  /// Crema de marca. Fondo por defecto del modo claro.
  static const Color cream = Color(0xFFF8EEDB);

  /// Vino de marca. Color primario.
  static const Color wine = Color(0xFF6B2639);

  // — Escala del vino ——————————————————————————————————————————
  static const Color wineDeep = Color(0xFF4A1927);
  static const Color wineSoft = Color(0xFF8E3A50);
  static const Color wineMist = Color(0xFFD9BFC7);

  // — Escala de la crema ———————————————————————————————————————
  static const Color creamLight = Color(0xFFFDF7EC);
  static const Color creamDeep = Color(0xFFEFE0C7);

  // — Tinta (texto) ————————————————————————————————————————————
  static const Color ink = Color(0xFF2A1720);
  static const Color inkMuted = Color(0xFF6E5A62);
  static const Color inkFaint = Color(0xFFA3919A);

  // — Acentos ——————————————————————————————————————————————————
  /// Dorado cálido: rachas, logros, estrellas de calificación.
  static const Color gold = Color(0xFFD9A441);

  /// Terracota: actividades de "Crear".
  static const Color clay = Color(0xFFC96F53);

  /// Salvia: actividades de "Reflexionar".
  static const Color sage = Color(0xFF6F8F72);

  // — Superficies oscuras ——————————————————————————————————————
  static const Color night = Color(0xFF1A0E14);
  static const Color nightElevated = Color(0xFF241419);
  static const Color nightBorder = Color(0xFF3A252D);

  // — Estado ———————————————————————————————————————————————————
  static const Color success = Color(0xFF4E7C59);
  static const Color danger = Color(0xFFB3403F);

  // — Cristal (liquid glass) ———————————————————————————————————
  static const Color glassLightFill = Color(0x66FFFFFF);
  static const Color glassLightStroke = Color(0x59FFFFFF);
  static const Color glassDarkFill = Color(0x1FFFFFFF);
  static const Color glassDarkStroke = Color(0x26FFFFFF);
}
