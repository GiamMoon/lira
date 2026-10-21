import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../library/presentation/widgets/generated_cover.dart';
import '../view_model/reader_state.dart';

class ChapterIndex extends StatelessWidget {
  const ChapterIndex({required this.state, required this.onSelect, super.key});
  final ReaderState state;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Container(
        width: AppLayout.readerIndexWidth,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: theme.dividerColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(Insets.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LIRA / LECTOR', style: theme.textTheme.labelSmall),
                  const SizedBox(height: Insets.xl),
                  SizedBox(
                    width: AppLayout.indexCoverWidth,
                    child: GeneratedCover(book: state.book, radius: Radii.xs),
                  ),
                  const SizedBox(height: Insets.lg),
                  Text(
                    state.book.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: Insets.sm),
                  Text(state.book.author, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: Insets.xl),
                  Text(
                    'CONTENIDO · ${state.chapters.length} CAPÍTULOS',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(Insets.md),
                itemCount: state.chapters.length,
                itemBuilder: (context, index) {
                  final active = index == state.currentIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Insets.xs),
                    child: ListTile(
                      selected: active,
                      selectedColor: theme.colorScheme.primary,
                      selectedTileColor: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Radii.sm),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Insets.md,
                      ),
                      leading: Text(
                        '${index + 1}'.padLeft(2, '0'),
                        style: theme.textTheme.labelSmall,
                      ),
                      title: Text(
                        state.chapters[index].title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: active
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      onTap: active ? null : () => onSelect(index),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Insets.xl),
              child: Text(
                'Ctrl + ← / → para cambiar de capítulo',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
