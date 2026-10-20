import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/book.dart';

/// Portada de un libro.
///
/// Si la obra trae imagen, se usa. Si no —que es lo normal con literatura de
/// dominio público— Lira **dibuja** una portada determinista a partir del id:
/// el mismo libro siempre se ve igual, y la estantería nunca muestra huecos
/// grises ni el clásico placeholder roto.
class GeneratedCover extends StatelessWidget {
  const GeneratedCover({required this.book, this.radius = Radii.md, super.key});

  final Book book;
  final double radius;

  static const List<List<Color>> _palettes = <List<Color>>[
    <Color>[AppColors.wineDeep, AppColors.wine],
    <Color>[AppColors.wine, AppColors.clay],
    <Color>[AppColors.night, AppColors.wineSoft],
    <Color>[Color(0xFF2F4436), AppColors.sage],
    <Color>[AppColors.clay, AppColors.gold],
    <Color>[Color(0xFF3B2A4A), AppColors.wineSoft],
  ];

  /// Hash estable entre ejecuciones y plataformas (no usa `String.hashCode`,
  /// que no garantiza el mismo valor fuera del proceso actual).
  static int _seedOf(String id) {
    var hash = 7;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    final seed = _seedOf(book.id);
    final palette = _palettes[seed % _palettes.length];
    final borderRadius = BorderRadius.circular(radius);
    final cover = book.coverUrl;

    return AspectRatio(
      aspectRatio: 2 / 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.wine.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: cover == null
              ? _PaintedCover(book: book, palette: palette, seed: seed)
              : Image.network(
                  cover,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, _) =>
                      _PaintedCover(book: book, palette: palette, seed: seed),
                  frameBuilder: (context, child, frame, wasSync) =>
                      frame == null && !wasSync
                      ? _PaintedCover(
                          book: book,
                          palette: palette,
                          seed: seed,
                        )
                      : child,
                ),
        ),
      ),
    );
  }
}

class _PaintedCover extends StatelessWidget {
  const _PaintedCover({
    required this.book,
    required this.palette,
    required this.seed,
  });

  final Book book;
  final List<Color> palette;
  final int seed;

  /// Ancho de referencia: el que ocupa una portada en la rejilla.
  static const double _anchoBase = 165;

  /// Por debajo de esto el texto no se leería de todos modos, y el título ya
  /// está escrito al lado. Se deja sólo la pintura.
  static const double _anchoMinimoConTexto = 110;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = restricciones.maxWidth;
        final pintura = CustomPaint(
          painter: _CoverPainter(palette: palette, seed: seed),
          size: Size.infinite,
        );

        // La misma portada se usa a 165, 92 y 64 píxeles de ancho. Sin esto,
        // el texto pensado para la rejilla desborda en las miniaturas.
        if (ancho < _anchoMinimoConTexto) return pintura;

        final escala = (ancho / _anchoBase).clamp(0.72, 1.4);

        return CustomPaint(
          painter: _CoverPainter(palette: palette, seed: seed),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Insets.lg * escala,
              Insets.md * escala,
              Insets.md * escala,
              Insets.md * escala,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  book.category.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.cream.withValues(alpha: 0.65),
                    fontSize: 9 * escala,
                    letterSpacing: 1.8 * escala,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    book.title,
                    maxLines: escala < 0.9 ? 3 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.cream,
                      fontSize: 17 * escala,
                      height: 1.15,
                    ),
                  ),
                ),
                SizedBox(height: Insets.xs * escala),
                Container(
                  width: 22 * escala,
                  height: 2,
                  color: AppColors.cream.withValues(alpha: 0.5),
                ),
                SizedBox(height: Insets.sm * escala),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.cream.withValues(alpha: 0.75),
                    letterSpacing: 0.4,
                    fontSize: 10.5 * escala,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CoverPainter extends CustomPainter {
  const _CoverPainter({required this.palette, required this.seed});

  final List<Color> palette;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ).createShader(rect),
    );

    // Dos halos de luz colocados según el id: dan variedad sin aleatoriedad.
    final halo = Offset(
      size.width * (0.2 + (seed % 5) * 0.14),
      size.height * (0.18 + (seed % 3) * 0.12),
    );
    canvas.drawCircle(
      halo,
      size.width * 0.62,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            AppColors.cream.withValues(alpha: 0.16),
            AppColors.cream.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: halo, radius: size.width * 0.62)),
    );

    // Lomo: la franja oscura del canto izquierdo que hace que se lea "libro".
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * 0.07, size.height),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.07, 0, 1, size.height),
      Paint()..color = AppColors.cream.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant _CoverPainter old) =>
      old.seed != seed || old.palette != palette;
}
