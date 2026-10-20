import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/pressable.dart';

/// Calificación de 1 a 5 estrellas, o ninguna.
///
/// Tocar la estrella ya marcada quita la calificación: nadie queda atrapado
/// en una nota que puso sin querer.
class StarRating extends StatelessWidget {
  const StarRating({required this.stars, required this.onRate, super.key});

  /// `null` = todavía no calificó.
  final int? stars;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final current = stars ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var value = 1; value <= 5; value++)
          Pressable(
            onTap: () => onRate(value),
            pressedScale: 0.88,
            child: Padding(
              padding: const EdgeInsets.only(right: Insets.sm),
              child: AnimatedScale(
                scale: value <= current ? 1.1 : 1,
                duration: Motion.fast,
                curve: Motion.overshoot,
                child: Icon(
                  value <= current
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 38,
                  color: value <= current
                      ? AppColors.gold
                      : AppColors.inkFaint.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
