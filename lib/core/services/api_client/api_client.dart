import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../api_service/api_service.dart';
import '../secure_storage_service/secure_storage_service.dart';
import '../storage_service/storage_service.dart';
import '../../utils/log_util.dart';

/// API 客户端
/// 基于 ApiService，处理 token 刷新和接口缓存
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final ApiService _apiService = ApiService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final StorageService _storage = StorageService();

  /// 是否正在刷新 token
  bool _isRefreshing = false;

  /// 待重试请求队列
  final List<_RetryRequest> _retryQueue = [];

  /// Token 刷新接口路径
  String refreshTokenPath = '/auth/refresh';

  ApiClient._internal();

  // ==================== 统一请求方法 ====================

  /// 统一请求方法
  /// [method] 请求方法，默认为 GET
  /// [params] 请求参数 (Query或Body)
  /// [useCache] 是否使用缓存，仅对 GET 请求有效，默认 false
  /// [cacheMinutes] 缓存时长（分钟），默认 5
  Future<ApiResponse<T>> request<T>(
    String path, {
    HttpMethod method = HttpMethod.get,
    dynamic params,
    bool useCache = false,
    int cacheMinutes = 5,
  }) async {
    // 检查缓存（仅 GET 请求）
    if (useCache) {
      final cached = await _getCache<T>(path, params, cacheMinutes);
      if (cached != null) {
        return cached;
      }
    }

    final response = await _request<T>(
      path,
      method: method,
      params: params,
      useCache: useCache,
      cacheMinutes: cacheMinutes,
    );

    // 保存缓存（仅 GET 请求成功时）
    if (response.isSuccess && useCache) {
      await _setCache(path, params, response.data);
    }

    return response;
  }

  // ==================== 内部请求方法 ====================

  Future<ApiResponse<T>> _request<T>(
    String path, {
    required HttpMethod method,
    dynamic params,
    required bool useCache,
    required int cacheMinutes,
  }) async {
    // 添加 token（如果存在）
    Options? options;
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options = Options(headers: {'Authorization': 'Bearer $token'});
    }

    final response = await _apiService.request<T>(
      path,
      method: method,
      params: params,
      options: options,
    );

    // 处理 401 未授权
    if (!response.isSuccess && response.code == 401) {
      return await _handle401<T>(
        path,
        method: method,
        params: params,
        useCache: useCache,
        cacheMinutes: cacheMinutes,
      );
    }

    return response;
  }

  /// 处理 401 未授权响应
  Future<ApiResponse<T>> _handle401<T>(
    String path, {
    required HttpMethod method,
    dynamic params,
    required bool useCache,
    required int cacheMinutes,
  }) async {
    // 如果正在刷新，加入队列等待
    if (_isRefreshing) {
      return await _addToRetryQueue<T>(
        path,
        method: method,
        params: params,
        useCache: useCache,
        cacheMinutes: cacheMinutes,
      );
    }

    _isRefreshing = true;

    try {
      // 尝试刷新 token
      final refreshSuccess = await _refreshToken();

      if (!refreshSuccess) {
        // 刷新失败，清除 token
        await _clearTokens();
        return ApiResponse.error(code: 401, message: '登录已过期，请重新登录');
      }

      // 刷新成功，重试原请求
      return await _request<T>(
        path,
        method: method,
        params: params,
        useCache: useCache,
        cacheMinutes: cacheMinutes,
      );
    } finally {
      _isRefreshing = false;

      // 处理队列中的请求
      _processRetryQueue();
    }
  }

  /// 刷新 token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _apiService.request<Map<String, dynamic>>(
        refreshTokenPath,
        method: HttpMethod.post,
        params: {'refreshToken': refreshToken},
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final accessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (accessToken != null) {
          await _secureStorage.setAccessToken(accessToken);
          if (newRefreshToken != null) {
            await _secureStorage.setRefreshToken(newRefreshToken);
          }
          LogUtil.log('Token 刷新成功');
          return true;
        }
      }

      return false;
    } catch (e) {
      LogUtil.log('Token 刷新失败: $e');
      return false;
    }
  }

  /// 清除所有 token
  Future<void> _clearTokens() async {
    await _secureStorage.clearAll();
  }

  /// 添加到重试队列
  Future<ApiResponse<T>> _addToRetryQueue<T>(
    String path, {
    required HttpMethod method,
    dynamic params,
    required bool useCache,
    required int cacheMinutes,
  }) async {
    final completer = Completer<ApiResponse<T>>();

    _retryQueue.add(_RetryRequest(
      path: path,
      method: method,
      params: params,
      useCache: useCache,
      cacheMinutes: cacheMinutes,
      completer: completer,
    ));

    return completer.future;
  }

  /// 处理重试队列
  void _processRetryQueue() async {
    for (final request in _retryQueue) {
      final response = await _request<dynamic>(
        request.path,
        method: request.method,
        params: request.params,
        useCache: request.useCache,
        cacheMinutes: request.cacheMinutes,
      );
      request.completer.complete(response);
    }
    _retryQueue.clear();
  }

  // ==================== 缓存方法 ====================

  /// 生成缓存 key
  String _generateCacheKey(String path, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) {
      return path;
    }
    final sortedKeys = params.keys.toList()..sort();
    final queryString = sortedKeys.map((key) => '$key=${params[key]}').join('&');
    return '$path?$queryString';
  }

  /// 获取缓存数据
  Future<ApiResponse<T>?> _getCache<T>(
    String path,
    Map<String, dynamic>? params,
    int cacheMinutes,
  ) async {
    try {
      final cacheKey = _generateCacheKey(path, params);
      final cacheData = _storage.getApiCache(cacheKey);

      if (cacheData == null) {
        return null;
      }

      final cacheJson = jsonDecode(cacheData) as Map<String, dynamic>;
      final timestamp = cacheJson['timestamp'] as int?;
      final data = cacheJson['data'];

      if (timestamp == null || data == null) {
        await _storage.removeApiCache(cacheKey);
        return null;
      }

      // 检查缓存是否过期
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = cacheMinutes * 60 * 1000;

      if (cacheAge > maxAge) {
        await _storage.removeApiCache(cacheKey);
        return null;
      }

      LogUtil.log('Cache hit: $cacheKey');
      return ApiResponse.success(data as T?);
    } catch (e) {
      LogUtil.log('Cache read error: $e');
      return null;
    }
  }

  /// 保存缓存数据
  Future<void> _setCache(String path, Map<String, dynamic>? params, dynamic data) async {
    try {
      final cacheKey = _generateCacheKey(path, params);
      final cacheJson = jsonEncode({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      });
      await _storage.setApiCache(cacheKey, cacheJson);
    } catch (e) {
      LogUtil.log('Cache write error: $e');
    }
  }

  /// 清除所有 API 缓存
  Future<void> clearCache() async {
    await _storage.clearApiCache();
  }

  /// 登出
  Future<void> logout() async {
    await _clearTokens();
    await clearCache();
  }
}

/// 重试请求
class _RetryRequest {
  final String path;
  final HttpMethod method;
  final dynamic params;
  final bool useCache;
  final int cacheMinutes;
  final Completer<ApiResponse<dynamic>> completer;

  _RetryRequest({
    required this.path,
    required this.method,
    this.params,
    required this.useCache,
    required this.cacheMinutes,
    required this.completer,
  });
}

/// 全局 ApiClient 实例
final apiClient = ApiClient();
