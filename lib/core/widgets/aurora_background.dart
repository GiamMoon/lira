import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    this.baseColor = AppColors.cream,
    this.intensity = 1,
    super.key,
  });

  final Color baseColor;

  /// 0 = plano, 1 = presencia normal. Útil para atenuarlo dentro del lector.
  final double intensity;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.aurora,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AuroraPainter(
          progress: _controller,
          baseColor: widget.baseColor,
          intensity: widget.intensity,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.progress,
    required this.baseColor,
    required this.intensity,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color baseColor;
  final double intensity;

  static const List<_Blob> _blobs = <_Blob>[
    _Blob(color: AppColors.wine, opacity: 0.16, radius: 0.55, phase: 0),
    _Blob(color: AppColors.gold, opacity: 0.14, radius: 0.42, phase: 0.33),
    _Blob(color: AppColors.wineSoft, opacity: 0.12, radius: 0.48, phase: 0.66),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);
    if (intensity <= 0) return;

    final t = progress.value * 2 * math.pi;
    final shortest = size.shortestSide;

    for (var i = 0; i < _blobs.length; i++) {
      final blob = _blobs[i];
      final angle = t + blob.phase * 2 * math.pi;
      final center = Offset(
        size.width * (0.5 + 0.34 * math.cos(angle + i)),
        size.height * (0.42 + 0.26 * math.sin(angle * 0.8 + i)),
      );
      final radius = shortest * blob.radius;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              blob.color.withValues(alpha: blob.opacity * intensity),
              blob.color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.baseColor != baseColor || old.intensity != intensity;
}

class _Blob {
  const _Blob({
    required this.color,
    required this.opacity,
    required this.radius,
    required this.phase,
  });

  final Color color;
  final double opacity;
  final double radius;
  final double phase;
}
