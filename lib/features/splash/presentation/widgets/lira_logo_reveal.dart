import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Entrada del logo de Lira.
///
/// Tres capas de movimiento que se leen como una sola: aparición con rebote,
/// flotación continua (el gato "respira" dentro de su caja) y un barrido de
/// luz que recorre la caja una vez que ya está en su sitio.
class LiraLogoReveal extends StatefulWidget {
  const LiraLogoReveal({required this.intro, super.key});

  /// Animación maestra del splash (0 → 1).
  final Animation<double> intro;

  @override
  State<LiraLogoReveal> createState() => _LiraLogoRevealState();
}

class _LiraLogoRevealState extends State<LiraLogoReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = CurvedAnimation(
    parent: widget.intro,
    curve: const Interval(0, 0.35, curve: Motion.enter),
  );

  late final Animation<double> _scale = Tween<double>(begin: 0.82, end: 1)
      .animate(
        CurvedAnimation(
          parent: widget.intro,
          curve: const Interval(0, 0.55, curve: Motion.overshoot),
        ),
      );

  late final Animation<double> _sheen = CurvedAnimation(
    parent: widget.intro,
    curve: const Interval(0.42, 0.95, curve: Curves.easeInOutSine),
  );

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[widget.intro, _float]),
      builder: (context, child) {
        final floatOffset = Tween<double>(
          begin: -6,
          end: 6,
        ).transform(Curves.easeInOut.transform(_float.value));

        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, floatOffset * _opacity.value),
            child: Transform.scale(scale: _scale.value, child: child),
          ),
        );
      },
      child: _LogoCard(sheen: _sheen),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard({required this.sheen});

  final Animation<double> sheen;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Radii.xl);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.wine.withValues(alpha: 0.22),
            blurRadius: 48,
            spreadRadius: -8,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: AnimatedBuilder(
          animation: sheen,
          builder: (context, child) => ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              // El barrido viaja de izquierda a derecha y desaparece al final.
              final position = sheen.value * 2 - 0.5;
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: <double>[
                  (position - 0.18).clamp(0.0, 1.0),
                  position.clamp(0.0, 1.0),
                  (position + 0.18).clamp(0.0, 1.0),
                ],
                colors: <Color>[
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.35 * (1 - sheen.value)),
                  Colors.white.withValues(alpha: 0),
                ],
              ).createShader(bounds);
            },
            child: child,
          ),
          child: Image.asset(
            AppAssets.logo,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
