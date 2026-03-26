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

  /// 格式化为 JSON 字符串
  static String _formatJson(Object? message) {
    try {
      if (message is String) {
        // 尝试解析字符串是否已经是 JSON
        final decoded = json.decode(message);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return const JsonEncoder.withIndent('  ').convert(message);
    } catch (e) {
      // 当解析 JSON 失败时，输出提示信息并附带原始文本内容
      return '⚠️ [Invalid JSON Format] Outputting as text:\n${message?.toString()}';
    }
  }
}
