import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lira/core/di/core_providers.dart';
import 'package:lira/core/storage/key_value_store.dart';
import 'package:lira/features/reader/presentation/view_model/reader_settings.dart';

/// Almacén en memoria: el ViewModel depende de la interfaz, así que la
/// preferencia se puede probar sin `SharedPreferences` ni plugins.
class _FakeStore implements KeyValueStore {
  _FakeStore([Map<String, String>? inicial])
    : _valores = <String, String>{...?inicial};

  final Map<String, String> _valores;

  @override
  String? readString(String key) => _valores[key];

  @override
  Future<void> writeString(String key, String value) async =>
      _valores[key] = value;

  @override
  bool? readBool(String key) => null;

  @override
  Future<void> writeBool(String key, {required bool value}) async {}

  @override
  Future<void> remove(String key) async => _valores.remove(key);
}

({ProviderContainer container, _FakeStore store}) _buildContainer({
  String? guardado,
}) {
  final store = _FakeStore(
    guardado == null
        ? null
        : <String, String>{StorageKeys.readerTextSize: guardado},
  );
  final container = ProviderContainer(
    overrides: [keyValueStoreProvider.overrideWithValue(store)],
  );
  addTearDown(container.dispose);
  return (container: container, store: store);
}

void main() {
  group('ReaderSettings', () {
    test('sin preferencia guardada arranca en normal', () {
      final harness = _buildContainer();

      expect(
        harness.container.read(readerSettingsProvider),
        ReaderTextSize.normal,
      );
    });

    test('recuerda el tamaño elegido en sesiones anteriores', () {
      final harness = _buildContainer(guardado: 'huge');

      expect(
        harness.container.read(readerSettingsProvider),
        ReaderTextSize.huge,
      );
    });

    test('un valor corrupto no rompe la lectura', () {
      final harness = _buildContainer(guardado: 'gigantesco');

      expect(
        harness.container.read(readerSettingsProvider),
        ReaderTextSize.normal,
        reason: 'ante un dato invalido se vuelve al tamaño por defecto',
      );
    });

    test('elegir un tamaño lo persiste', () async {
      final harness = _buildContainer();

      await harness.container
          .read(readerSettingsProvider.notifier)
          .select(ReaderTextSize.large);

      expect(
        harness.container.read(readerSettingsProvider),
        ReaderTextSize.large,
      );
      expect(harness.store.readString(StorageKeys.readerTextSize), 'large');
    });

    test('la escala crece con el tamaño', () {
      final escalas = ReaderTextSize.values
          .map((tamano) => tamano.scale)
          .toList();

      expect(escalas, orderedEquals(<double>[...escalas]..sort()));
      expect(ReaderTextSize.normal.scale, 1.0);
    });
  });
}
