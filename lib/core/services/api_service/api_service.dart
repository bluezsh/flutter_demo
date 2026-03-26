import 'package:dio/dio.dart';
import '../../utils/log_util.dart';

/// 网络请求方法枚举
enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch,
}

/// 统一网络请求响应类
class ApiResponse<T> {
  final T? data;
  final int? code;
  final String? message;
  final bool isSuccess;

  ApiResponse.success(this.data)
      : isSuccess = true,
        code = 200,
        message = null;

  ApiResponse.error({this.code, this.message, this.data}) : isSuccess = false;

  @override
  String toString() => isSuccess
      ? 'ApiResponse.success(data: $data)'
      : 'ApiResponse.error(code: $code, message: $message, data: $data)';
}

/// 网络请求服务封装
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json; charset=utf-8',
    ));
  }

  /// 统一请求方法 (始终返回 ApiResponse，不抛出异常)
  /// [path] 请求路径
  /// [method] 请求方法，默认为 [HttpMethod.get]
  /// [params] 请求参数 (Query或Body)
  /// [options] Dio 配置覆盖
  Future<ApiResponse<T>> request<T>(
    String path, {
    HttpMethod method = HttpMethod.get,
    Object? params,
    Options? options,
  }) async {
    final stopwatch = Stopwatch()..start();
    final methodStr = method.name.toUpperCase();

    try {
      Response response;
      if (method == HttpMethod.get) {
        response = await _dio.get(
          path,
          queryParameters: params as Map<String, dynamic>?,
          options: options,
        );
      } else {
        response = await _dio.request(
          path,
          data: params,
          options: (options ?? Options()).copyWith(method: methodStr),
        );
      }

      stopwatch.stop();

      // 记录成功日志
      LogUtil.logApi(
        path: path,
        method: methodStr,
        params: params,
        response: response.data,
        duration: stopwatch.elapsed,
      );

      return ApiResponse.success(response.data as T?);
    } on DioException catch (e) {
      stopwatch.stop();

      final apiError = _handleDioError(e);

      // 记录错误日志
      LogUtil.logApi(
        path: path,
        method: methodStr,
        params: params,
        response: apiError.message,
        duration: stopwatch.elapsed,
        isError: true,
      );

      return ApiResponse.error(
        code: apiError.code,
        message: apiError.message,
        data: apiError.data as T?,
      );
    } catch (e) {
      stopwatch.stop();

      final unknownErrorMessage = e.toString();

      LogUtil.logApi(
        path: path,
        method: methodStr,
        params: params,
        response: unknownErrorMessage,
        duration: stopwatch.elapsed,
        isError: true,
      );

      return ApiResponse.error(
        code: -4,
        message: unknownErrorMessage,
      );
    }
  }

  /// 处理 Dio 异常并转换为内部错误模型
  _InternalError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return _InternalError(code: -1, message: '网络连接超时');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return _InternalError(
          code: statusCode,
          message: '服务器响应异常: $statusCode',
          data: error.response?.data,
        );
      case DioExceptionType.cancel:
        return _InternalError(code: -2, message: '请求已取消');
      case DioExceptionType.connectionError:
        return _InternalError(code: -3, message: '网络连接错误');
      default:
        return _InternalError(code: -4, message: '未知网络错误: ${error.message}');
    }
  }
}

/// 内部错误模型，仅供 ApiService 内部使用
class _InternalError {
  final int? code;
  final String message;
  final dynamic data;
  _InternalError({this.code, required this.message, this.data});
}

/// 全局 ApiService 实例
final apiService = ApiService();
