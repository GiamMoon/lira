import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/storage/key_value_store.dart';

part 'reader_settings.g.dart';

/// Tamaños de letra del lector.
///
/// Cuatro pasos y no un deslizador continuo: elegir es más rápido que afinar,
/// y así ningún estudiante acaba con una medida ilegible.
enum ReaderTextSize {
  small('Pequeño', 0.88),
  normal('Normal', 1.0),
  large('Grande', 1.18),
  huge('Enorme', 1.38);

  const ReaderTextSize(this.label, this.scale);

  final String label;
  final double scale;
}

/// Preferencia de lectura, recordada entre sesiones.
///
/// Quien necesita letra grande la necesita **siempre**: tener que ajustarla en
/// cada libro sería una barrera, no una opción.
@Riverpod(keepAlive: true)
class ReaderSettings extends _$ReaderSettings {
  @override
  ReaderTextSize build() {
    final guardado = ref
        .watch(keyValueStoreProvider)
        .readString(StorageKeys.readerTextSize);

    return ReaderTextSize.values.firstWhere(
      (tamano) => tamano.name == guardado,
      orElse: () => ReaderTextSize.normal,
    );
  }

  Future<void> select(ReaderTextSize tamano) async {
    if (tamano == state) return;
    await ref
        .read(keyValueStoreProvider)
        .writeString(StorageKeys.readerTextSize, tamano.name);
    state = tamano;
  }
}
