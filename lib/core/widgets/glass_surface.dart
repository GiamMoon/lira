import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Superficie de "liquid glass": desenfoque del fondo + relleno translúcido +
/// borde de luz. Es el material base de Lira para cualquier panel flotante
/// (tarjetas, barras, hojas, diálogos).
///
/// Se implementa una sola vez para que el efecto sea idéntico en toda la app y
/// para poder degradarlo en un único sitio si hiciera falta por rendimiento.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    this.padding = const EdgeInsets.all(Insets.lg),
    this.borderRadius,
    this.blur = 18,
    this.opacity = 1,
    this.tint,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double blur;

  /// Permite animar la aparición del cristal sin envolverlo en otro widget.
  final double opacity;

  /// Tinte opcional sobre el cristal (p. ej. vino para acciones primarias).
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final radius = borderRadius ?? BorderRadius.circular(Radii.lg);
    final fill = tint != null
        ? tint!.withValues(alpha: isLight ? 0.18 : 0.24)
        : (isLight ? AppColors.glassLightFill : AppColors.glassDarkFill);
    final stroke = isLight
        ? AppColors.glassLightStroke
        : AppColors.glassDarkStroke;

    return Opacity(
      opacity: opacity,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: stroke, width: 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  fill,
                  fill.withValues(alpha: fill.a * 0.55),
                ],
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
