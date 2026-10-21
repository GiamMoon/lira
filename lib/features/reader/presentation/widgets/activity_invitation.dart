import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/entities/activity.dart';

/// La invitación del final de capítulo.
///
/// Es una **invitación**, no un examen: "Seguir leyendo" es una opción más,
/// del mismo tamaño que las otras, y nada se bloquea si la ignora.
class ActivityInvitation extends StatelessWidget {
  const ActivityInvitation({
    required this.activities,
    required this.onChoose,
    required this.onSkip,
    required this.answeredIds,
    super.key,
  });

  final List<Activity> activities;
  final ValueChanged<Activity> onChoose;
  final VoidCallback onSkip;
  final Set<String> answeredIds;

  static Color colorOf(ActivityKind kind) => switch (kind) {
    ActivityKind.reflexionar => AppColors.sage,
    ActivityKind.crear => AppColors.clay,
    ActivityKind.queHarias => AppColors.gold,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.65,
        ),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: AppColors.wine.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '¿Quieres hacer una actividad?',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 15.5),
          ),
          const SizedBox(height: Insets.xs),
          Text(
            'No hay respuestas correctas. Puedes saltártela.',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.5),
          ),
          const SizedBox(height: Insets.lg),
          for (final activity in activities) ...<Widget>[
            _Option(
              emoji: activity.kind.emoji,
              label: activity.kind.label,
              accent: colorOf(activity.kind),
              isDone: answeredIds.contains(activity.id),
              onTap: () => onChoose(activity),
            ),
            const SizedBox(height: Insets.sm),
          ],
          _Option(
            emoji: '📖',
            label: 'Seguir leyendo',
            accent: AppColors.inkMuted,
            isDone: false,
            onTap: onSkip,
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.emoji,
    required this.label,
    required this.accent,
    required this.isDone,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color accent;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.lg,
          vertical: Insets.md,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 17)),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 14),
              ),
            ),
            if (isDone)
              Icon(Icons.check_rounded, size: 17, color: accent)
            else
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: accent.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}
