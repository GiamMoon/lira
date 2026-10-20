import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

/// Implementación de [KeyValueStore] sobre `SharedPreferences`.
class PrefsKeyValueStore implements KeyValueStore {
  const PrefsKeyValueStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  bool? readBool(String key) => _prefs.getBool(key);

  @override
  Future<void> writeBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  @override
  String? readString(String key) => _prefs.getString(key);

  @override
  Future<void> writeString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}
