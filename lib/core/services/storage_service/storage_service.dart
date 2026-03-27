import 'package:shared_preferences/shared_preferences.dart';

/// 存储键枚举
enum StorageKey {
  /// API 缓存 (使用时传入接口路径)
  apiCache('api_cache_');

  final String prefix;
  const StorageKey(this.prefix);
}

/// 本地存储服务
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  SharedPreferences? _prefs;

  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _storage {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  String? getString(StorageKey key, {String? defaultValue}) =>
      _storage.getString(key.prefix) ?? defaultValue;

  Future<bool> setString(StorageKey key, String value) =>
      _storage.setString(key.prefix, value);

  int? getInt(StorageKey key, {int? defaultValue}) =>
      _storage.getInt(key.prefix) ?? defaultValue;

  Future<bool> setInt(StorageKey key, int value) =>
      _storage.setInt(key.prefix, value);

  double? getDouble(StorageKey key, {double? defaultValue}) =>
      _storage.getDouble(key.prefix) ?? defaultValue;

  Future<bool> setDouble(StorageKey key, double value) =>
      _storage.setDouble(key.prefix, value);

  bool? getBool(StorageKey key, {bool? defaultValue}) =>
      _storage.getBool(key.prefix) ?? defaultValue;

  Future<bool> setBool(StorageKey key, bool value) =>
      _storage.setBool(key.prefix, value);

  List<String>? getStringList(StorageKey key, {List<String>? defaultValue}) =>
      _storage.getStringList(key.prefix) ?? defaultValue;

  Future<bool> setStringList(StorageKey key, List<String> value) =>
      _storage.setStringList(key.prefix, value);

  bool containsKey(StorageKey key) => _storage.containsKey(key.prefix);
  Future<bool> remove(StorageKey key) => _storage.remove(key.prefix);
  Future<bool> clear() => _storage.clear();

  /// API 缓存操作
  String _cacheKey(String endpoint) => '${StorageKey.apiCache.prefix}$endpoint';

  Future<bool> setApiCache(String endpoint, String data) =>
      _storage.setString(_cacheKey(endpoint), data);

  String? getApiCache(String endpoint) =>
      _storage.getString(_cacheKey(endpoint));

  Future<bool> removeApiCache(String endpoint) =>
      _storage.remove(_cacheKey(endpoint));

  Future<void> clearApiCache() async {
    for (final key in _storage.getKeys()) {
      if (key.startsWith(StorageKey.apiCache.prefix)) {
        await _storage.remove(key);
      }
    }
  }
}

final storageService = StorageService();
