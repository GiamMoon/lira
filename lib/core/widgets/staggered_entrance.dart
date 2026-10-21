import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

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

  final int index;

  final double offset;

  final Duration stepDelay;

  /// Limita la espera en listas largas.
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
  Timer? _delay;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _delay?.cancel();
      _controller.value = 1;
      return;
    }
    if (_scheduled) return;
    _scheduled = true;
    final pasos = widget.index.clamp(0, widget.maxSteps);
    _delay = Timer(widget.stepDelay * pasos, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
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
