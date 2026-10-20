import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/entities/book.dart';

/// Filtro por forma literaria. `null` = Todos.
class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final BookCategory? selected;
  final ValueChanged<BookCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <BookCategory?>[null, ...BookCategory.values];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: Insets.sm),
        itemBuilder: (context, index) {
          final option = options[index];
          return _Chip(
            label: option?.label ?? 'Todos',
            isSelected: option == selected,
            onTap: () => onSelected(option),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.enter,
        padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.wine : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(
            color: isSelected
                ? AppColors.wine
                : theme.colorScheme.outline.withValues(alpha: 0.7),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 13,
            color: isSelected ? AppColors.creamLight : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
