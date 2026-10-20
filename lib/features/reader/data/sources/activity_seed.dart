import '../../domain/entities/activity.dart';

/// Dinámicas de muestra para el modo sin conexión.
///
/// Fíjate en la forma de la consigna: no se puede responder bien ni mal, no
/// pregunta "qué quiso decir el autor" y apunta al lector, no al texto. Ese es
/// el molde para escribir las que vayan a Supabase.
abstract final class ActivitySeed {
  static const Map<String, List<Activity>> _byBook = <String, List<Activity>>{
    'las-aventuras-de-tom-sawyer': <Activity>[
      Activity(
        id: 'tom-sawyer-1-reflexionar',
        bookId: 'las-aventuras-de-tom-sawyer',
        chapterId: 'tom-sawyer-1',
        kind: ActivityKind.reflexionar,
        prompt:
            'Tom se escapa por la ventana y su tía lo sabe, pero igual lo '
            'deja. ¿Hay alguien que te conozca así de bien?',
        hint: 'Una frase basta. Nadie más la va a leer.',
      ),
    ],
  };

  static List<Activity> forBook(String bookId) =>
      _byBook[bookId] ?? const <Activity>[];
}
