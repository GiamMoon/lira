import '../../domain/entities/chapter.dart';
import '../../domain/entities/content_block.dart';

/// Capítulo de muestra para el modo sin conexión.
///
/// Es el **texto auténtico** del primer capítulo de *Las aventuras de Tom
/// Sawyer*, obra de dominio público (Mark Twain, 1876), así que puede viajar
/// dentro de la app sin problema.
///
/// El resto del catálogo se sirve desde Supabase. Una obra sin capítulos aquí
/// —como John Wesley, cuyo texto tiene licencia y no vive en el repo— hace que
/// el lector muestre "Todavía no cargamos este texto", que es la verdad.
abstract final class ChapterSeed {
  static const Map<String, List<Chapter>> _byBook = <String, List<Chapter>>{
    'las-aventuras-de-tom-sawyer': <Chapter>[
      Chapter(
        id: 'tom-sawyer-1',
        bookId: 'las-aventuras-de-tom-sawyer',
        position: 0,
        title: 'Diabluras de Tom (1/3)',
        blocks: <ContentBlock>[
          ParagraphBlock('—¡Tom!'),
          ParagraphBlock('Silencio.'),
          ParagraphBlock('—¡Tom!'),
          ParagraphBlock('Silencio.'),
          ParagraphBlock('—¿Dónde se habrá metido ese muchacho? ¡Oye, Tom!'),
          ParagraphBlock('Silencio.'),
          ParagraphBlock(
            'La anciana se bajó las gafas y echó una ojeada a la estancia por '
            'encima de ellas; luego se las volvió a colocar y miró por '
            'debajo. Pocas veces o nunca miraba a través de las gafas para '
            'fijarse en un ser tan insignificante como un muchacho; eran un '
            'atributo de dignidad, el orgullo de su corazón, y estaban '
            'destinadas a «figurar», no a servir; del mismo modo hubiese '
            'podido mirar a través de un par de tapaderas de estufa. Se quedó '
            'perpleja un instante y luego dijo, no con fiereza, pero en voz '
            'bastante alta para que la oyeran los muebles:',
          ),
          ParagraphBlock('—Ya verás si te pongo la mano encima lo que…'),
          ParagraphBlock(
            'No concluyó la frase, ya que se había agachado para hurgar con '
            'la escoba por debajo de la cama, por lo que precisaba aliento '
            'para puntuar los escobazos. Solo resucitó al gato.',
          ),
          ParagraphBlock('—No hay manera de atrapar a ese granuja.'),
          ParagraphBlock(
            'Se dirigió hacia la puerta abierta, se detuvo allí y recorrió '
            'con la mirada las tomateras y las plantas de estramonio que '
            'constituían el jardín. Ni rastro de Tom. Entonces levantó la voz '
            'al tono exigido por la distancia y gritó:',
          ),
          ParagraphBlock('—¡Tooom!'),
          ParagraphBlock(
            'A su espalda oyó un ligero ruido y se volvió con el tiempo justo '
            'de atrapar a un niño pequeño por el faldón de la chaqueta y '
            'detener su huida.',
          ),
          ParagraphBlock(
            '—No sé cómo no se me había ocurrido que estarías en la despensa. '
            '¿Qué hacías ahí dentro?',
          ),
          ParagraphBlock('—Nada.'),
          ParagraphBlock(
            '—¡Nada! Mírate las manos. Y mírate la boca. ¿Qué son esas '
            'manchas?',
          ),
          ParagraphBlock('—No lo sé, tía.'),
          ParagraphBlock(
            '—Bueno, yo sí que lo sé. Eso es mermelada. Te he dicho mil veces '
            'que si no dejabas en paz la mermelada te arrancaría la piel. '
            'Dame aquella vara.',
          ),
          ParagraphBlock(
            'La vara se agitó en el aire; el peligro era inminente.',
          ),
          ParagraphBlock('—¡Mire a su espalda, tía!'),
          ParagraphBlock(
            'La anciana se dio la vuelta enseguida, asiéndose las faldas para '
            'apartarlas del peligro. Entretanto el muchacho se escapó, '
            'saltando por el alto vallado de estacas, y desapareció.',
          ),
          ParagraphBlock(
            'La tía Polly se quedó unos instantes perpleja y luego se echó a '
            'reír suavemente.',
          ),
          ParagraphBlock(
            '—Maldito chico, ¿es que no aprenderé nunca? ¿No me ha hecho ya '
            'bastantes jugarretas como esa para que espere atraparlo ahora? '
            'Pero un tonto viejo es el peor tonto que existe. Ya lo dice el '
            'refrán, «perro viejo no aprende trucos nuevos». Y, válgame el '
            'cielo, si cada día la treta es diferente, ¿cómo va una a saberla '
            'de antemano? Parece que sepa exactamente cuánto puede '
            'atormentarme sin hacerme perder la cabeza, y que si puede '
            'distraerme un minuto o hacerme reír, se me pasa el enfado y no '
            'puedo darle un cachete. No cumplo mi deber con el muchacho; esa '
            'es la verdad y bien lo sabe Dios. Ahorrar el palo hace al '
            'muchacho malo, como dice la Biblia. Estoy pecando y sufro por '
            'los dos, lo sé. El chico es de la piel de Barrabás, pero al fin '
            'y al cabo es el hijo de mi difunta hermana, pobrecilla, y no '
            'tengo valor para azotarle. Cada vez que le perdono me remuerde '
            'la conciencia, y cada vez que le pego se parte mi viejo corazón. '
            'Es cierto que hombre nacido de mujer tiene una vida corta y '
            'llena de tribulaciones, como dicen las Escrituras, y convengo en '
            'que así es. Esta tarde hará novillos y no me quedará otro '
            'remedio que hacerle trabajar mañana para castigarlo. Me duele '
            'hacerle trabajar los sábados mientras los demás muchachos tienen '
            'fiesta, pero él aborrece el trabajo más que nada en el mundo, y '
            'poco o mucho tengo que cumplir con mi deber o seré la ruina del '
            'chico.',
          ),
          ParagraphBlock(
            'Tom hizo novillos y se divirtió mucho. Volvió a casa justo a '
            'tiempo para ayudar a Jim, el muchacho de color, aserró la leña '
            'para el siguiente día y partió las teas antes de la cena; por lo '
            'menos llegó a tiempo para contarle sus hazañas a Jim, mientras '
            'este hacía las tres cuartas partes del trabajo. El hermano menor '
            'de Tom (o, mejor dicho, su hermanastro), Sid, había concluido ya '
            'su parte en la tarea (recoger las astillas). Sid era un niño '
            'tranquilo y de temperamento poco dado a las aventuras.',
          ),
          ParagraphBlock(
            'Mientras Tom cenaba, escamoteando azúcar cuando se le ofrecía la '
            'oportunidad, la tía Polly le hacía preguntas profundísimas y '
            'llenas de artificio para atraparlo en revelaciones '
            'perjudiciales. Como muchas otras almas candorosas, tenía la '
            'vanidad de creerse dotada de un talento especial para la '
            'diplomacia oscura y misteriosa, y le gustaba considerar sus '
            'sencillas tretas como maravillas de sagacidad.',
          ),
          ParagraphBlock(
            '—Tom, hacía bastante calor en la escuela, ¿verdad? —dijo.',
          ),
        ],
      ),
    ],
  };

  /// Una obra sin texto cargado devuelve lista vacía; el lector lo resuelve
  /// con un estado vacío honesto en vez de reventar.
  static List<Chapter> forBook(String bookId) =>
      _byBook[bookId] ?? const <Chapter>[];
}
