import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/key_value_store.dart';
import '../storage/prefs_key_value_store.dart';

part 'core_providers.g.dart';

/// Punto de inyección de `SharedPreferences`.
///
/// Se resuelve en `main()` con `overrideWithValue`, de modo que el árbol de
/// widgets nunca espera un `Future` y los tests pueden inyectar un doble.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('sharedPreferencesProvider debe sobreescribirse');

@Riverpod(keepAlive: true)
KeyValueStore keyValueStore(Ref ref) =>
    PrefsKeyValueStore(ref.watch(sharedPreferencesProvider));
