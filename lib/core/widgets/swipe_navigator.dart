import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Deslizar a los lados para ir al siguiente o al anterior.
///
/// Es el gesto que todo el mundo trae aprendido de las stories y de los
/// carruseles, y en un lector ahorra tener que bajar hasta el botón cada vez.
/// El botón **sigue estando**: esto es un atajo, no la única manera.
///
/// Sólo reacciona a un gesto rápido y con recorrido. Con un umbral flojo,
/// cualquier arrastre en diagonal mientras se lee cambiaba de capítulo, que
/// es la peor forma de perder el sitio.
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

  /// Píxeles por segundo a partir de los cuales el gesto cuenta.
  static const double _velocidadMinima = 260;

  void _onDragEnd(DragEndDetails details) {
    final velocidad = details.primaryVelocity ?? 0;
    if (velocidad.abs() < _velocidadMinima) return;

    final accion = velocidad < 0 ? onNext : onPrevious;
    if (accion == null) return;

    // El toque se confirma en la mano, no sólo en la pantalla: sin esto el
    // gesto se siente a medias cuando el cambio de capítulo tarda un instante.
    unawaited(HapticFeedback.lightImpact());
    accion();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // El scroll vertical del texto manda: este reconocedor sólo se lleva el
      // gesto cuando es claramente horizontal.
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
