import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Indicador de carga de marca: una hebra de tinta que recorre un riel crema.
///
/// Reemplaza al `CircularProgressIndicator` genérico; ocupa poco y mantiene el
/// tono editorial de Lira.
class BrandProgress extends StatefulWidget {
  const BrandProgress({required this.intro, this.width = 132, super.key});

  final Animation<double> intro;
  final double width;

  @override
  State<BrandProgress> createState() => _BrandProgressState();
}

class _BrandProgressState extends State<BrandProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  late final Animation<double> _reveal = CurvedAnimation(
    parent: widget.intro,
    curve: const Interval(0.6, 0.9, curve: Motion.enter),
  );

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_sweep, _reveal]),
      builder: (context, _) => Opacity(
        opacity: _reveal.value,
        child: SizedBox(
          width: widget.width,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: CustomPaint(painter: _ThreadPainter(progress: _sweep.value)),
          ),
        ),
      ),
    );
  }
}

class _ThreadPainter extends CustomPainter {
  const _ThreadPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()..color = AppColors.wine.withValues(alpha: 0.14),
    );

    const threadFraction = 0.42;
    final threadWidth = size.width * threadFraction;
    // Va y vuelve con easing, como una aguja de telar.
    final eased = Curves.easeInOutCubic.transform(
      progress <= 0.5 ? progress * 2 : (1 - progress) * 2,
    );
    final left = (size.width + threadWidth) * eased - threadWidth;

    canvas.drawRect(
      Rect.fromLTWH(left, 0, threadWidth, size.height),
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0x006B2639), AppColors.wine, Color(0x006B2639)],
        ).createShader(Rect.fromLTWH(left, 0, threadWidth, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _ThreadPainter old) => old.progress != progress;
}
