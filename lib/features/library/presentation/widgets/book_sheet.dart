import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_progress.dart';
import 'generated_cover.dart';

/// Ficha de la obra antes de entrar a leer.
///
/// Da contexto (de qué va, cuánto dura) y una sola acción evidente. Si ya se
/// está leyendo, aparece además la salida discreta para dejarlo.
Future<void> showBookSheet(
  BuildContext context, {
  required Book book,
  required VoidCallback onStart,
  required VoidCallback onAbandon,
  ReadingProgress? progress,
}) {
  return showAdaptiveSheet<void>(
    context: context,
    builder: (sheetContext) => _BookSheet(
      book: book,
      progress: progress,
      onStart: onStart,
      onAbandon: onAbandon,
    ),
  );
}

class _BookSheet extends StatelessWidget {
  const _BookSheet({
    required this.book,
    required this.onStart,
    required this.onAbandon,
    this.progress,
  });

  final Book book;
  final ReadingProgress? progress;
  final VoidCallback onStart;
  final VoidCallback onAbandon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reading = progress;
    final isReading = reading != null && reading.isActive;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.86,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Insets.xl,
            Insets.md,
            Insets.xl,
            Insets.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.wineMist,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                ),
              ),
              const SizedBox(height: Insets.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 92, child: GeneratedCover(book: book)),
                  const SizedBox(width: Insets.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          book.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: Insets.xs),
                        Text(book.author, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: Insets.md),
                        Wrap(
                          spacing: Insets.sm,
                          runSpacing: Insets.sm,
                          children: <Widget>[
                            _MetaChip(label: book.category.label),
                            _MetaChip(label: '${book.minutesToRead} min'),
                            _MetaChip(label: '${book.chapterCount} capítulos'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Insets.xl),
              Text(
                book.synopsis,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
              if (book.tags.isNotEmpty) ...<Widget>[
                const SizedBox(height: Insets.lg),
                Wrap(
                  spacing: Insets.sm,
                  children: <Widget>[
                    for (final tag in book.tags) _MetaChip(label: '#$tag'),
                  ],
                ),
              ],
              const SizedBox(height: Insets.xxl),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onStart();
                },
                child: Text(isReading ? 'Seguir leyendo' : 'Empezar a leer'),
              ),
              if (isReading) ...<Widget>[
                const SizedBox(height: Insets.sm),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAbandon();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    child: const Text('Dejar este libro'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.wine.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.wine, letterSpacing: 0.2, fontSize: 11),
      ),
    );
  }
}
