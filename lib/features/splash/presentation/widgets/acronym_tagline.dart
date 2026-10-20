import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// El acrónimo de Lira desplegado: **L**ectura · **I**nformación ·
/// **R**ecursos · **A**prendizaje.
///
/// Las iniciales se resaltan en vino para que el nombre se "explique" solo,
/// y el interletrado se abre durante la entrada.
class AcronymTagline extends StatelessWidget {
  const AcronymTagline({required this.intro, super.key});

  final Animation<double> intro;

  static const List<String> _words = <String>[
    'Lectura',
    'Información',
    'Recursos',
    'Aprendizaje',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
      color: AppColors.inkMuted,
      fontSize: 11.5,
    );
    final initial = base.copyWith(
      color: AppColors.wine,
      fontWeight: FontWeight.w800,
    );

    final reveal = CurvedAnimation(
      parent: intro,
      curve: const Interval(0.45, 0.8, curve: Motion.enter),
    );

    return AnimatedBuilder(
      animation: reveal,
      builder: (context, _) => Opacity(
        opacity: reveal.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - reveal.value)),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                for (var i = 0; i < _words.length; i++) ...<InlineSpan>[
                  TextSpan(text: _words[i][0].toUpperCase(), style: initial),
                  TextSpan(text: _words[i].substring(1).toUpperCase()),
                  if (i != _words.length - 1)
                    const TextSpan(text: '   ·   '),
                ],
              ],
            ),
            textAlign: TextAlign.center,
            style: base.copyWith(letterSpacing: 1 + 1.4 * reveal.value),
          ),
        ),
      ),
    );
  }
}
