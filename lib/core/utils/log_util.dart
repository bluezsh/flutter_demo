import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 日志输出格式枚举
enum LogFormat {
  text,
  json,
}

/// 日志工具类
class LogUtil {
  static const String _tag = 'APP_LOG';

  /// 打印日志
  /// [message] 日志内容
  /// [format] 输出格式，默认为 [LogFormat.text]
  static void log(Object? message, {LogFormat format = LogFormat.text}) {
    if (!kDebugMode) return;

    String output;
    if (format == LogFormat.json) {
      output = _formatJson(message);
    } else {
      output = message?.toString() ?? 'null';
    }

    // 使用 dart:developer 的 log 函数，它可以更好地集成到 DevTools 中
    // 并且通常比 print/debugPrint 更适合大型日志输出
    developer.log(
      output,
      name: _tag,
      time: DateTime.now(),
    );
  }

  /// 打印接口请求日志 (原子化输出，避免并发混淆)
  static void logApi({
    required String path,
    required String method,
    Object? params,
    Object? response,
    required Duration duration,
    bool isError = false,
  }) {
    if (!kDebugMode) return;

    final StringBuffer sb = StringBuffer();
    sb.writeln('🚀 [API ${isError ? 'ERROR' : 'RESPONSE'}]');
    sb.writeln('  - Path: $path');
    sb.writeln('  - Method: ${method.toUpperCase()}');
    sb.writeln('  - Duration: ${duration.inMilliseconds}ms');

    if (params != null) {
      sb.writeln('  - Parameters:');
      sb.writeln(_formatJson(params, indent: '    '));
    }

    if (response != null) {
      sb.writeln('  - Response:');
      sb.writeln(_formatJson(response, indent: '    '));
    }

    sb.write('-------------------------------------------');

    developer.log(
      sb.toString(),
      name: 'API_LOG',
      time: DateTime.now(),
      level: isError ? 1000 : 0,
    );
  }

  /// 格式化为 JSON 字符串
  static String _formatJson(Object? message, {String indent = '  '}) {
    try {
      final encoder = JsonEncoder.withIndent(indent);
      if (message is String) {
        final decoded = json.decode(message);
        return encoder.convert(decoded);
      }
      return encoder.convert(message);
    } catch (e) {
      return '$indent⚠️ [Invalid JSON Format] Outputting as text:\n$indent${message?.toString()}';
    }
  }
}
