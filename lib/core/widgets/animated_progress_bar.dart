import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    required this.value,
    this.height = 3,
    this.color = AppColors.wine,
    this.background,
    super.key,
  });

  /// 0.0 a 1.0.
  final double value;
  final double height;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final pista = background ?? color.withValues(alpha: 0.15);
    final quieto = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      label: 'Progreso de lectura',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.pill),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
          duration: quieto ? Duration.zero : const Duration(milliseconds: 900),
          curve: Motion.emphasized,
          builder: (context, animado, _) => LinearProgressIndicator(
            value: animado,
            minHeight: height,
            backgroundColor: pista,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ),
    );
  }
}
