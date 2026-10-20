import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Entrada escalonada: el contenido aparece subiendo y con un retraso que
/// depende de su posición en la lista.
///
/// Es lo que hace que una rejilla se sienta "servida" en vez de volcada de
/// golpe. Se centraliza aquí para que el ritmo sea el mismo en toda la app.
///
/// Respeta la preferencia de accesibilidad "reducir movimiento": si el sistema
/// la tiene activada, el contenido aparece sin animación en vez de ignorarla.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    required this.child,
    this.index = 0,
    this.offset = 22,
    this.stepDelay = const Duration(milliseconds: 55),
    this.maxSteps = 12,
    super.key,
  });

  final Widget child;

  /// Posición en la lista. Marca cuánto espera antes de entrar.
  final int index;

  /// Cuánto sube al aparecer, en píxeles.
  final double offset;

  final Duration stepDelay;

  /// Tope de retrasos acumulables: sin esto, el elemento 40 de una rejilla
  /// entraría más de dos segundos tarde.
  final int maxSteps;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.slow,
  );

  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: Motion.emphasized,
  );

  @override
  void initState() {
    super.initState();
    final pasos = widget.index.clamp(0, widget.maxSteps);
    Future<void>.delayed(widget.stepDelay * pasos, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) => Opacity(
        opacity: _curved.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curved.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
