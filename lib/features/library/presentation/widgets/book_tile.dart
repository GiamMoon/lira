import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_progress.dart';
import 'generated_cover.dart';

/// Una obra en la estantería.
class BookTile extends StatelessWidget {
  const BookTile({
    required this.book,
    required this.onTap,
    this.onLongPress,
    this.progress,
    super.key,
  });

  final Book book;
  final ReadingProgress? progress;
  final VoidCallback onTap;

  /// Atajo de quien ya sabe lo que quiere: mantener pulsado abre el libro
  /// directamente, sin pasar por la ficha. Nulo = sólo toque.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reading = progress;

    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // La portada NO va dentro de un Expanded: si lo estuviera, un título
          // de dos líneas le robaría alto y esa portada saldría más pequeña
          // que la de al lado. Aquí manda siempre su propia proporción 2:3.
          Stack(
            children: <Widget>[
              GeneratedCover(book: book),
              if (book.isShort)
                Positioned(
                  top: Insets.sm,
                  right: Insets.sm,
                  child: _MinutesBadge(minutes: book.minutesToRead),
                ),
            ],
          ),
          const SizedBox(height: Insets.md),
          // Alto fijo: reserva dos líneas de título aunque solo ocupe una, y
          // así los autores y las barras quedan alineados entre tarjetas.
          SizedBox(
            height: 56 * MediaQuery.textScalerOf(context).scale(1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 14.5),
                ),
                const Spacer(),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.sm),
          SizedBox(
            height: 14 * MediaQuery.textScalerOf(context).scale(1),
            child: switch (reading?.status) {
              // Terminar un libro merece verse en la estantería: es la única
              // recompensa visible de haberlo hecho.
              ReadingStatus.finished => const _Terminado(),
              // Contra el total ACTUAL del libro: el guardado puede ser de
              // cuando la obra tenía otro número de capítulos.
              ReadingStatus.reading => _MiniProgress(
                fraction: reading!.fractionOf(book.chapterCount),
              ),
              _ => null,
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// "12 min" sobre la portada: la promesa de que esto no te va a costar la tarde.
class _MinutesBadge extends StatelessWidget {
  const _MinutesBadge({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        '$minutes min',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.wine, fontSize: 10, letterSpacing: 0.4),
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: AnimatedProgressBar(value: fraction)),
        const SizedBox(width: Insets.sm),
        Text(
          '${(fraction * 100).round()}%',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(fontSize: 10, letterSpacing: 0),
        ),
      ],
    );
  }
}

/// Marca de obra terminada.
class _Terminado extends StatelessWidget {
  const _Terminado();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.gold),
        const SizedBox(width: Insets.xs),
        Text(
          'Terminado',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            letterSpacing: 0.3,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}
