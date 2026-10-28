import 'package:shared_preferences/shared_preferences.dart';

/// Armazenamento chave-valor usado pelos repositórios acadêmicos locais.
///
/// Abstrai o mecanismo concreto para que os repositórios possam ser
/// testados em memória e, futuramente, substituídos por um backend remoto.
abstract interface class KeyValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// Persistência local via SharedPreferences (demo, sem criptografia).
class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> delete(String key) => _preferences.remove(key);
}

/// Restringe todas as chaves a um namespace (ex.: o UID do professor),
/// garantindo que repositórios de professores diferentes nunca leiam ou
/// sobrescrevam os dados uns dos outros.
class NamespacedKeyValueStore implements KeyValueStore {
  NamespacedKeyValueStore(this._inner, String namespace)
    : _prefix = '$namespace.';

  final KeyValueStore _inner;
  final String _prefix;

  @override
  Future<String?> read(String key) => _inner.read('$_prefix$key');

  @override
  Future<void> write(String key, String value) =>
      _inner.write('$_prefix$key', value);

  @override
  Future<void> delete(String key) => _inner.delete('$_prefix$key');
}

/// Implementação em memória, útil em testes.
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
