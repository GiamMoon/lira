import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/reading_font.dart';

part 'preferences_view_model.g.dart';

/// Lo que el estudiante ha decidido sobre cómo se ve y se lee Lira.
///
/// Vive en el dispositivo y no sube a ningún sitio: es una preferencia, no un
/// dato de la cuenta, y cada móvil puede tener la suya.
@immutable
class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.font = ReadingFont.serif,
    this.name = '',
  });

  final ThemeMode themeMode;
  final ReadingFont font;

  /// Cómo quiere que le llamen. Vacío es una respuesta válida: nada es
  /// obligatorio, tampoco esto.
  final String name;

  bool get hasName => name.trim().isNotEmpty;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    ReadingFont? font,
    String? name,
  }) => AppPreferences(
    themeMode: themeMode ?? this.themeMode,
    font: font ?? this.font,
    name: name ?? this.name,
  );
}

/// Preferencias de la app, recordadas entre sesiones.
///
/// `keepAlive` porque el tema lo consulta la raíz del árbol: si se reconstruye
/// al entrar y salir de Ajustes, la app parpadea entero.
@Riverpod(keepAlive: true)
class Preferences extends _$Preferences {
  @override
  AppPreferences build() {
    final store = ref.watch(keyValueStoreProvider);

    return AppPreferences(
      themeMode: _leerTema(store.readString(StorageKeys.themeMode)),
      font: ReadingFont.values.firstWhere(
        (fuente) => fuente.name == store.readString(StorageKeys.readingFont),
        orElse: () => ReadingFont.serif,
      ),
      name: store.readString(StorageKeys.studentName) ?? '',
    );
  }

  static ThemeMode _leerTema(String? guardado) => ThemeMode.values.firstWhere(
    (modo) => modo.name == guardado,
    orElse: () => ThemeMode.system,
  );

  Future<void> selectTheme(ThemeMode modo) async {
    if (modo == state.themeMode) return;
    await ref
        .read(keyValueStoreProvider)
        .writeString(StorageKeys.themeMode, modo.name);
    state = state.copyWith(themeMode: modo);
  }

  Future<void> selectFont(ReadingFont fuente) async {
    if (fuente == state.font) return;
    await ref
        .read(keyValueStoreProvider)
        .writeString(StorageKeys.readingFont, fuente.name);
    state = state.copyWith(font: fuente);
  }

  Future<void> setName(String nombre) async {
    final limpio = nombre.trim();
    if (limpio == state.name) return;
    await ref
        .read(keyValueStoreProvider)
        .writeString(StorageKeys.studentName, limpio);
    state = state.copyWith(name: limpio);
  }
}
