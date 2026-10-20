/// La obra pedida no existe o ya no está publicada.
///
/// Vive en el dominio de libros porque la necesitan varias features (el lector
/// y el cierre): una excepción compartida no puede colgar de la presentación
/// de ninguna de ellas.
class BookNotFoundException implements Exception {
  const BookNotFoundException(this.bookId);

  final String bookId;

  @override
  String toString() => 'BookNotFoundException($bookId)';
}
