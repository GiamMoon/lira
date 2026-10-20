import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_progress.dart';
import 'generated_cover.dart';

/// "Sigue donde lo dejaste".
///
/// Es la pieza más importante de la pantalla: reduce a un toque la distancia
/// entre abrir la app y volver a leer. Por eso ocupa el lugar más visible y
/// lleva su propio menú discreto para dejar el libro sin drama.
class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({
    required this.book,
    required this.progress,
    required this.onContinue,
    required this.onAbandon,
    super.key,
  });

  final Book book;
  final ReadingProgress progress;
  final VoidCallback onContinue;
  final VoidCallback onAbandon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chapter = (progress.chaptersRead + 1).clamp(1, book.chapterCount);

    return Pressable(
      onTap: onContinue,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(Insets.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.lg),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AppColors.wine, AppColors.wineDeep],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.wine.withValues(alpha: 0.32),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 64, child: GeneratedCover(book: book)),
            const SizedBox(width: Insets.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 2),
                  Text(
                    'SIGUE DONDE LO DEJASTE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.cream.withValues(alpha: 0.6),
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: Insets.sm),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.cream,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: Insets.xs),
                  Text(
                    'Capítulo $chapter de ${book.chapterCount}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.cream.withValues(alpha: 0.7),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: Insets.md),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: AnimatedProgressBar(
                          value: progress.fraction,
                          height: 5,
                          color: AppColors.gold,
                          background: AppColors.cream.withValues(alpha: 0.22),
                        ),
                      ),
                      const SizedBox(width: Insets.md),
                      Text(
                        '${progress.percent}%',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.cream,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _MoreOptions(onAbandon: onAbandon),
          ],
        ),
      ),
    );
  }
}

/// El "⋮" del que hablaba el brief: dejar un libro tiene que estar disponible,
/// pero nunca gritar.
class _MoreOptions extends StatelessWidget {
  const _MoreOptions({required this.onAbandon});

  final VoidCallback onAbandon;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: AppColors.cream.withValues(alpha: 0.6),
        size: 20,
      ),
      tooltip: 'Más opciones',
      itemBuilder: (context) => <PopupMenuEntry<void>>[
        PopupMenuItem<void>(
          onTap: onAbandon,
          child: const Row(
            children: <Widget>[
              Icon(Icons.bookmark_remove_outlined, size: 18),
              SizedBox(width: Insets.sm),
              Text('Dejar de leer'),
            ],
          ),
        ),
      ],
    );
  }
}
