import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/content_block.dart';

/// Pinta los bloques de un capítulo con tipografía de lectura.
///
/// Serif, línea alta y medida contenida: la pantalla imita la comodidad de una
/// página, no la densidad de una app.
class ChapterContent extends StatelessWidget {
  const ChapterContent({
    required this.blocks,
    this.scale = 1,
    this.style,
    super.key,
  });

  final List<ContentBlock> blocks;

  /// Tipografía elegida por el estudiante. Nula = la serif de la casa.
  final TextStyle? style;

  /// Multiplicador de tamano de letra elegido por el estudiante.
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? AppTypography.reading(theme.colorScheme.onSurface);
    final reading = base.copyWith(fontSize: (base.fontSize ?? 19) * scale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final block in blocks) ...<Widget>[
          _blockWidget(context, block, reading),
          SizedBox(height: block is DividerBlock ? Insets.xl : Insets.lg),
        ],
      ],
    );
  }

  Widget _blockWidget(
    BuildContext context,
    ContentBlock block,
    TextStyle reading,
  ) {
    final theme = Theme.of(context);

    return switch (block) {
      ParagraphBlock(:final text) => Text(text, style: reading),
      VerseBlock(:final lines) => _Stanza(lines: lines, reading: reading),
      HeadingBlock(:final text) => Padding(
        padding: const EdgeInsets.only(top: Insets.lg),
        child: Text(text, style: theme.textTheme.headlineMedium),
      ),
      QuoteBlock(:final text) => Container(
        padding: const EdgeInsets.only(left: Insets.lg),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.wine, width: 3)),
        ),
        child: Text(
          text,
          style: reading.copyWith(
            fontStyle: FontStyle.italic,
            color: AppColors.wine,
            fontSize: reading.fontSize! - 1,
          ),
        ),
      ),
      NoteBlock(:final text) => _EditorialNote(text: text),
      DividerBlock() => const _Ornament(),
    };
  }
}

/// Una estrofa: un verso por línea, sin justificar y sin reflotar.
///
/// Se sangra un poco respecto a la prosa para que se vea de un vistazo que
/// esto se lee distinto, y la línea va más apretada que en un párrafo: entre
/// versos manda el salto, no el aire.
class _Stanza extends StatelessWidget {
  const _Stanza({required this.lines, required this.reading});

  final List<String> lines;
  final TextStyle reading;

  @override
  Widget build(BuildContext context) {
    final verso = reading.copyWith(height: 1.55);

    return Padding(
      padding: const EdgeInsets.only(left: Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[for (final line in lines) Text(line, style: verso)],
      ),
    );
  }
}

/// Aviso de Lira, nunca texto del autor: por eso va en caja, en sans y con
/// marca explícita.
class _EditorialNote extends StatelessWidget {
  const _EditorialNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.gold,
          ),
          const SizedBox(width: Insets.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Separador de escena.
class _Ornament extends StatelessWidget {
  const _Ornament();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      child: Center(
        child: Text(
          '❦',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.wine.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
