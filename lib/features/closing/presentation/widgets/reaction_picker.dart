import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/entities/book_reaction.dart';

/// Las cinco reacciones, en multi-selección.
///
/// Emoji grande y etiqueta en palabras del estudiante ("Me dejó pensando"),
/// no en categorías de análisis literario.
class ReactionPicker extends StatelessWidget {
  const ReactionPicker({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final Set<BookReaction> selected;
  final ValueChanged<BookReaction> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: <Widget>[
        for (final reaction in BookReaction.values)
          _ReactionChip(
            reaction: reaction,
            isSelected: selected.contains(reaction),
            onTap: () => onToggle(reaction),
          ),
      ],
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.reaction,
    required this.isSelected,
    required this.onTap,
  });

  final BookReaction reaction;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Pressable(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1,
        duration: Motion.fast,
        curve: Motion.overshoot,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.enter,
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.lg,
            vertical: Insets.md,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.wine
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(
              color: isSelected
                  ? AppColors.wine
                  : theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(reaction.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: Insets.sm),
              Text(
                reaction.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 13.5,
                  color: isSelected
                      ? AppColors.creamLight
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
