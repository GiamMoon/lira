import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeNavigator extends StatelessWidget {
  const SwipeNavigator({
    required this.child,
    this.onNext,
    this.onPrevious,
    super.key,
  });

  final Widget child;

  /// Deslizar hacia la izquierda: avanzar. Nulo = no hay siguiente.
  final VoidCallback? onNext;

  /// Deslizar hacia la derecha: retroceder. Nulo = no hay anterior.
  final VoidCallback? onPrevious;

  static const double _velocidadMinima = 260;

  void _onDragEnd(DragEndDetails details) {
    final velocidad = details.primaryVelocity ?? 0;
    if (velocidad.abs() < _velocidadMinima) return;

    final accion = velocidad < 0 ? onNext : onPrevious;
    if (accion == null) return;

    unawaited(HapticFeedback.lightImpact());
    accion();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      supportedDevices: const {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      },
      // Sólo captura desplazamientos claramente horizontales.
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
