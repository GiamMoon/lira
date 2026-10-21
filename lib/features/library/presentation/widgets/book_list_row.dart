import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/hover_lift.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_progress.dart';
import 'generated_cover.dart';

class BookListRow extends StatelessWidget {
  const BookListRow({
    required this.book,
    required this.onTap,
    this.progress,
    super.key,
  });
  final Book book;
  final ReadingProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HoverLift(
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(Insets.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Row(
            children: [
              SizedBox(
                width: AppLayout.rowCoverWidth,
                child: GeneratedCover(book: book, radius: Radii.xs),
              ),
              const SizedBox(width: Insets.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: Insets.xs),
                    Text(book.author, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: Insets.sm),
                    Text(
                      book.synopsis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Insets.xl),
              Text(book.category.label, style: theme.textTheme.labelLarge),
              const SizedBox(width: Insets.xl),
              Text(
                progress == null
                    ? '${book.minutesToRead} min'
                    : '${(progress!.fractionOf(book.chapterCount) * 100).round()}% leído',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: Insets.lg),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
