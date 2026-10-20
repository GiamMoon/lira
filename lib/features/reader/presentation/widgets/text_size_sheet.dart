import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pressable.dart';
import '../view_model/reader_settings.dart';

/// Ajuste del tamaño de letra, con muestra en vivo.
///
/// El cambio se aplica al instante y sobre un texto de verdad: se elige
/// mirando cómo se lee, no adivinando qué significa "Grande".
Future<void> showTextSizeSheet(BuildContext context) {
  return showAdaptiveSheet<void>(
    context: context,
    builder: (_) => const _TextSizeSheet(),
  );
}

class _TextSizeSheet extends ConsumerWidget {
  const _TextSizeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final actual = ref.watch(readerSettingsProvider);
    final base = AppTypography.reading(theme.colorScheme.onSurface);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Insets.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Tamaño del texto',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: Insets.lg),
              AnimatedDefaultTextStyle(
                duration: Motion.medium,
                curve: Motion.emphasized,
                style: base.copyWith(
                  fontSize: (base.fontSize ?? 19) * actual.scale,
                ),
                child: const Text('Hay golpes en la vida, tan fuertes...'),
              ),
              const SizedBox(height: Insets.xl),
              Row(
                children: <Widget>[
                  for (final tamano in ReaderTextSize.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: Insets.sm),
                        child: _Opcion(
                          tamano: tamano,
                          activo: tamano == actual,
                          onTap: () => ref
                              .read(readerSettingsProvider.notifier)
                              .select(tamano),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.tamano,
    required this.activo,
    required this.onTap,
  });

  final ReaderTextSize tamano;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.enter,
        padding: const EdgeInsets.symmetric(vertical: Insets.md),
        decoration: BoxDecoration(
          color: activo ? AppColors.wine : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: activo
                ? AppColors.wine
                : theme.colorScheme.outline.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Aa',
              style: TextStyle(
                fontSize: 11 + 5 * tamano.scale,
                fontWeight: FontWeight.w600,
                color: activo
                    ? AppColors.creamLight
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tamano.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                letterSpacing: 0.3,
                color: activo ? AppColors.creamLight : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
