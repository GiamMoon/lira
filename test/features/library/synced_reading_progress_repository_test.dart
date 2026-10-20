import 'package:flutter_test/flutter_test.dart';
import 'package:lira/features/library/data/repositories/synced_reading_progress_repository.dart';
import 'package:lira/features/library/domain/entities/reading_progress.dart';
import 'package:lira/features/library/domain/repositories/reading_progress_repository.dart';

ReadingProgress progreso(String libro, int leidos, DateTime cuando) =>
    ReadingProgress(
      bookId: libro,
      chaptersRead: leidos,
      chapterCount: 96,
      status: ReadingStatus.reading,
      updatedAt: cuando,
    );

class _EnMemoria implements ReadingProgressRepository {
  _EnMemoria([List<ReadingProgress>? inicial]) {
    for (final p in inicial ?? const <ReadingProgress>[]) {
      guardado[p.bookId] = p;
    }
  }

  final Map<String, ReadingProgress> guardado = <String, ReadingProgress>{};

  /// Simula estar sin red.
  bool caido = false;

  @override
  Future<List<ReadingProgress>> fetchAll() async {
    if (caido) throw StateError('sin red');
    return guardado.values.toList();
  }

  @override
  Future<void> save(ReadingProgress progress) async {
    if (caido) throw StateError('sin red');
    guardado[progress.bookId] = progress;
  }

  @override
  Future<void> remove(String bookId) async {
    if (caido) throw StateError('sin red');
    guardado.remove(bookId);
  }
}

void main() {
  final ayer = DateTime(2026, 9, 19, 10);
  final hoy = DateTime(2026, 9, 20, 10);

  group('SyncedReadingProgressRepository', () {
    test('de cada libro gana la versión más reciente', () async {
      final local = _EnMemoria([progreso('tom', 40, hoy)]);
      final remoto = _EnMemoria([progreso('tom', 5, ayer)]);
      final sync = SyncedReadingProgressRepository(local, remoto);

      final resultado = await sync.fetchAll();

      expect(resultado.single.chaptersRead, 40);
      expect(
        remoto.guardado['tom']!.chaptersRead,
        40,
        reason: 'lo más reciente sube a la nube',
      );
    });

    test('el avance que ya había en el móvil sube la primera vez', () async {
      // El caso real: el estudiante leyó sin sesión y luego se abre una.
      final local = _EnMemoria([progreso('wesley', 12, hoy)]);
      final remoto = _EnMemoria();
      final sync = SyncedReadingProgressRepository(local, remoto);

      await sync.fetchAll();

      expect(remoto.guardado['wesley']?.chaptersRead, 12);
    });

    test('lo que sólo está en la nube baja al dispositivo', () async {
      // El caso de estrenar teléfono.
      final local = _EnMemoria();
      final remoto = _EnMemoria([progreso('sherlock', 7, hoy)]);
      final sync = SyncedReadingProgressRepository(local, remoto);

      final resultado = await sync.fetchAll();

      expect(resultado.single.bookId, 'sherlock');
      expect(local.guardado['sherlock']?.chaptersRead, 7);
    });

    test('sin red se lee lo del dispositivo y no revienta', () async {
      final local = _EnMemoria([progreso('tom', 3, hoy)]);
      final remoto = _EnMemoria()..caido = true;
      final sync = SyncedReadingProgressRepository(local, remoto);

      final resultado = await sync.fetchAll();

      expect(resultado.single.chaptersRead, 3);
    });

    test('guardar sin red conserva el avance en el dispositivo', () async {
      final local = _EnMemoria();
      final remoto = _EnMemoria()..caido = true;
      final sync = SyncedReadingProgressRepository(local, remoto);

      await sync.save(progreso('tom', 9, hoy));

      expect(
        local.guardado['tom']?.chaptersRead,
        9,
        reason: 'el dispositivo es el que no puede fallar',
      );
    });

    test('dejar un libro lo borra de los dos lados', () async {
      final local = _EnMemoria([progreso('tom', 3, hoy)]);
      final remoto = _EnMemoria([progreso('tom', 3, hoy)]);
      final sync = SyncedReadingProgressRepository(local, remoto);

      await sync.remove('tom');

      expect(local.guardado, isEmpty);
      expect(remoto.guardado, isEmpty);
    });
  });
}
