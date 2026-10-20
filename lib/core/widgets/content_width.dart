import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Conserva una medida cómoda sin estirar los controles en pantallas grandes.
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    required this.child,
    this.maxWidth = AppLayout.readingMaxWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}
