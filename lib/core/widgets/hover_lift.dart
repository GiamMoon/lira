import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class HoverLift extends StatefulWidget {
  const HoverLift({required this.child, super.key});
  final Widget child;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Motion.fast,
      curve: Motion.enter,
      transform: Matrix4.translationValues(
        0,
        _hovered ? -AppLayout.hoverOffset : 0,
        0,
      ),
      child: widget.child,
    ),
  );
}
