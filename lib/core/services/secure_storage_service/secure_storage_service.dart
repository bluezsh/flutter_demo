import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token 类型枚举
enum TokenType {
  /// 访问令牌
  accessToken('access_token'),

  /// 刷新令牌
  refreshToken('refresh_token');

  final String key;
  const TokenType(this.key);
}

/// 安全存储服务封装
/// 专门用于存储用户 Token
/// 使用 Keychain(iOS) / Keystore(Android) 安全存储
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  final FlutterSecureStorage _storage;

  SecureStorageService._internal()
      : _storage = const FlutterSecureStorage();

  /// 保存 Token
  Future<void> setToken(TokenType type, String value) async {
    await _storage.write(key: type.key, value: value);
  }

  /// 获取 Token
  Future<String?> getToken(TokenType type) async {
    return await _storage.read(key: type.key);
  }

  /// 删除 Token
  Future<void> deleteToken(TokenType type) async {
    await _storage.delete(key: type.key);
  }

  /// 保存访问令牌
  Future<void> setAccessToken(String value) => setToken(TokenType.accessToken, value);

  /// 获取访问令牌
  Future<String?> getAccessToken() => getToken(TokenType.accessToken);

  /// 保存刷新令牌
  Future<void> setRefreshToken(String value) => setToken(TokenType.refreshToken, value);

  /// 获取刷新令牌
  Future<String?> getRefreshToken() => getToken(TokenType.refreshToken);

  /// 删除所有 Token
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

/// 全局 SecureStorageService 实例
final secureStorageService = SecureStorageService();
