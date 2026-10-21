import 'package:flutter/foundation.dart';

/// Un bloque de contenido dentro de un capítulo.
///
/// El texto se guarda **estructurado**, no como un blob ni como PDF. Eso es lo
/// que permite reflotarlo en cualquier pantalla, medir el avance de verdad y,
/// sobre todo, poder insertar cosas entre bloques sin pelearse con una maqueta
/// fija.
@immutable
sealed class ContentBlock {
  const ContentBlock();

  /// Parseo polimórfico desde la columna `chapters.body` (jsonb).
  /// Un tipo desconocido degrada a párrafo en vez de romper la lectura.
  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final text = (json['text'] as String?) ?? '';
    return switch (json['type'] as String?) {
      'h' => HeadingBlock(text),
      'v' => VerseBlock(text),
      'quote' => QuoteBlock(text),
      'note' => NoteBlock(text),
      'hr' => const DividerBlock(),
      _ => ParagraphBlock(text),
    };
  }

  Map<String, dynamic> toJson();
}

final class ParagraphBlock extends ContentBlock {
  const ParagraphBlock(this.text);

  final String text;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'type': 'p', 'text': text};
}

final class HeadingBlock extends ContentBlock {
  const HeadingBlock(this.text);

  final String text;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'type': 'h', 'text': text};
}

/// Una estrofa. El salto de línea del autor es parte de la obra: un poema
/// reflotado como prosa deja de ser el poema.
///
/// Por eso los versos de una misma estrofa viajan juntos en un solo bloque,
/// separados por `\n`, y no como párrafos sueltos: así el espacio entre
/// estrofas se distingue del espacio entre versos.
final class VerseBlock extends ContentBlock {
  const VerseBlock(this.text);

  final String text;

  List<String> get lines => text.split('\n');

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'type': 'v', 'text': text};
}

final class QuoteBlock extends ContentBlock {
  const QuoteBlock(this.text);

  final String text;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': 'quote',
    'text': text,
  };
}

/// Aviso editorial de Lira, no parte de la obra. Se pinta distinto para que
/// nunca se confunda con el texto del autor.
final class NoteBlock extends ContentBlock {
  const NoteBlock(this.text);

  final String text;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': 'note',
    'text': text,
  };
}

final class DividerBlock extends ContentBlock {
  const DividerBlock();

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'type': 'hr'};
}
