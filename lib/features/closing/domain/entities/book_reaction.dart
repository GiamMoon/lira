/// Cómo te dejó la historia.
///
/// No es una valoración ni una nota: es lo que sentiste. Se pueden elegir
/// varias a la vez —un libro puede molestar y gustar al mismo tiempo— y
/// ninguna es "mejor" que otra.
enum BookReaction {
  surprised('Me sorprendió', '😮', 'sorpresa'),
  sad('Me dio pena', '🥺', 'pena'),
  angry('Me molestó', '😡', 'molestia'),
  thoughtful('Me dejó pensando', '🤔', 'pensativo'),
  loved('Me gustó', '❤️', 'gusto');

  const BookReaction(this.label, this.emoji, this.storageName);

  final String label;
  final String emoji;

  /// Valor en la columna `book_reactions.reaction`.
  final String storageName;

  static BookReaction? fromStorage(String value) {
    for (final reaction in BookReaction.values) {
      if (reaction.storageName == value) return reaction;
    }
    return null;
  }
}
