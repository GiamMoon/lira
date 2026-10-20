import 'package:flutter/foundation.dart';

import 'content_block.dart';

/// Un capítulo de una obra.
///
/// La unidad de lectura *y* la unidad de progreso: "voy por el 3 de 8" es algo
/// que un estudiante entiende; "página 47" no dice nada en un teléfono.
@immutable
class Chapter {
  const Chapter({
    required this.id,
    required this.bookId,
    required this.position,
    required this.title,
    required this.blocks,
  });

  final String id;
  final String bookId;

  /// 0 = primer capítulo.
  final int position;
  final String title;
  final List<ContentBlock> blocks;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Chapter && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
