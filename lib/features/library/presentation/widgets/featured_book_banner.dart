import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/book.dart';
import 'generated_cover.dart';

class FeaturedBookBanner extends StatelessWidget {
  const FeaturedBookBanner({
    required this.book,
    required this.onOpen,
    super.key,
  });
  final Book book;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: AppLayout.heroHeight),
      padding: const EdgeInsets.all(Insets.xxl),
      decoration: BoxDecoration(
        color: AppColors.wineDeep,
        borderRadius: BorderRadius.circular(Radii.lg),
        gradient: const LinearGradient(
          colors: [AppColors.wineDeep, AppColors.wine],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TU SIGUIENTE GRAN DESCUBRIMIENTO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.creamDeep,
                  ),
                ),
                const SizedBox(height: Insets.lg),
                Text(
                  'Haz espacio para\nuna historia.',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: AppColors.creamLight,
                    fontSize: AppLayout.desktopTitleSize,
                  ),
                ),
                const SizedBox(height: Insets.lg),
                Text(
                  'Hay mundos que empiezan con una sola página.\nEncuentra el tuyo, sin prisa.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.creamDeep,
                  ),
                ),
                const SizedBox(height: Insets.xl),
                FilledButton.icon(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.creamLight,
                    foregroundColor: AppColors.wineDeep,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Descubrir esta obra'),
                ),
              ],
            ),
          ),
          const SizedBox(width: Insets.xl),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Transform.rotate(
                    angle: -0.08,
                    child: SizedBox(
                      width: AppLayout.heroCoverWidth,
                      child: GeneratedCover(book: book, radius: Radii.sm),
                    ),
                  ),
                ),
                const SizedBox(width: Insets.xl),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.category.label.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.creamDeep,
                        ),
                      ),
                      const SizedBox(height: Insets.md),
                      Text(
                        book.title,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.creamLight,
                        ),
                      ),
                      const SizedBox(height: Insets.sm),
                      Text(
                        book.author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.creamDeep,
                        ),
                      ),
                      const SizedBox(height: Insets.lg),
                      Text(
                        '${book.minutesToRead} min de lectura',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.creamDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
