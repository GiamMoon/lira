import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lira/core/di/core_providers.dart';
import 'package:lira/core/storage/key_value_store.dart';
import 'package:lira/features/settings/domain/entities/reading_font.dart';
import 'package:lira/features/settings/presentation/view_model/preferences_view_model.dart';

/// Almacén en memoria: las preferencias dependen de la interfaz, así que se
/// prueban sin `SharedPreferences` ni plugins.
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

({ProviderContainer container, _FakeStore store}) _build([
  Map<String, String>? guardado,
]) {
  final store = _FakeStore(guardado);
  final container = ProviderContainer(
    overrides: [keyValueStoreProvider.overrideWithValue(store)],
  );
  addTearDown(container.dispose);
  return (container: container, store: store);
}

void main() {
  group('Preferences', () {
    test('sin nada guardado sigue al sistema, serif y sin nombre', () {
      final prefs = _build().container.read(preferencesProvider);

      expect(prefs.themeMode, ThemeMode.system);
      expect(prefs.font, ReadingFont.serif);
      expect(prefs.name, isEmpty);
      expect(prefs.hasName, isFalse);
    });

    test('recuerda lo elegido en sesiones anteriores', () {
      final prefs = _build(<String, String>{
        StorageKeys.themeMode: 'dark',
        StorageKeys.readingFont: 'legible',
        StorageKeys.studentName: 'Ana',
      }).container.read(preferencesProvider);

      expect(prefs.themeMode, ThemeMode.dark);
      expect(prefs.font, ReadingFont.legible);
      expect(prefs.name, 'Ana');
    });

    test('un valor corrupto no rompe el arranque', () {
      final prefs = _build(<String, String>{
        StorageKeys.themeMode: 'sepia',
        StorageKeys.readingFont: 'comic',
      }).container.read(preferencesProvider);

      expect(prefs.themeMode, ThemeMode.system);
      expect(prefs.font, ReadingFont.serif);
    });

    test('elegir tema, letra y nombre lo persiste', () async {
      final harness = _build();
      final notifier = harness.container.read(preferencesProvider.notifier);

      await notifier.selectTheme(ThemeMode.dark);
      await notifier.selectFont(ReadingFont.sans);
      await notifier.setName('  Giampier  ');

      final prefs = harness.container.read(preferencesProvider);
      expect(prefs.themeMode, ThemeMode.dark);
      expect(prefs.font, ReadingFont.sans);
      expect(
        prefs.name,
        'Giampier',
        reason: 'el nombre se guarda sin los espacios de sobra',
      );
      expect(harness.store.readString(StorageKeys.themeMode), 'dark');
      expect(harness.store.readString(StorageKeys.readingFont), 'sans');
      expect(harness.store.readString(StorageKeys.studentName), 'Giampier');
    });

    test('el nombre se puede borrar: nada es obligatorio', () async {
      final harness = _build(<String, String>{StorageKeys.studentName: 'Ana'});

      await harness.container.read(preferencesProvider.notifier).setName('');

      expect(harness.container.read(preferencesProvider).hasName, isFalse);
    });

    test('las tres letras de lectura son distintas de verdad', () {
      final familias = ReadingFont.values
          .map((fuente) => fuente.style(const Color(0xFF000000)).fontFamily)
          .toSet();

      expect(
        familias,
        hasLength(ReadingFont.values.length),
        reason: 'ofrecer tres opciones que se ven igual sería mentir',
      );
    });
  });
}
