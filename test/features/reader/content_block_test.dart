import 'package:flutter_test/flutter_test.dart';
import 'package:lira/features/reader/domain/entities/content_block.dart';

void main() {
  group('ContentBlock', () {
    test(
      'un tipo desconocido degrada a párrafo en vez de romper la lectura',
      () {
        final bloque = ContentBlock.fromJson(<String, dynamic>{
          'type': 'tabla-interactiva-del-futuro',
          'text': 'Algo que esta versión no sabe pintar.',
        });

        expect(bloque, isA<ParagraphBlock>());
        expect(
          (bloque as ParagraphBlock).text,
          'Algo que esta versión no sabe pintar.',
        );
      },
    );

    test('el verso conserva los saltos de línea del autor', () {
      final bloque = ContentBlock.fromJson(<String, dynamic>{
        'type': 'v',
        'text':
            'Volverán las oscuras golondrinas\n'
            'en tu balcón sus nidos a colgar',
      });

      expect(bloque, isA<VerseBlock>());
      expect((bloque as VerseBlock).lines, <String>[
        'Volverán las oscuras golondrinas',
        'en tu balcón sus nidos a colgar',
      ]);
    });

    test('una estrofa sobrevive a ida y vuelta por JSON', () {
      const original = VerseBlock('uno\ndos\ntres');

      final vuelta = ContentBlock.fromJson(original.toJson());

      expect(vuelta, isA<VerseBlock>());
      expect((vuelta as VerseBlock).text, original.text);
    });

    test('un verso no se confunde con un párrafo', () {
      const verso = VerseBlock('uno\ndos');
      const parrafo = ParagraphBlock('uno dos');

      expect(verso.toJson()['type'], 'v');
      expect(parrafo.toJson()['type'], 'p');
    });
  });
}
