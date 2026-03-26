import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/router/app_router.dart' show navigatorKey;

/// Toast 工具类
class ToastUtil {
  ToastUtil._();

  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;
  static Timer? _autoDismissTimer;

  /// 显示纯文本 Toast
  /// [message] 显示的文本
  /// [duration] 持续时间，默认2秒
  static void show(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showCustom(
      child: _TextToastWidget(message: message),
      duration: duration,
      position: ToastPosition.center,
    );
  }

  /// 显示自定义 Widget Toast
  /// [child] 自定义 Widget
  /// [duration] 持续时间，null表示不自动消失
  /// [position] 显示位置，默认居中
  /// [dismissOnTap] 点击是否关闭，默认true
  static void showCustom({
    required Widget child,
    Duration? duration,
    ToastPosition position = ToastPosition.center,
    bool dismissOnTap = true,
  }) {
    // 如果已有 toast 显示，先移除
    if (_isShowing) {
      hide();
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => _CustomToastWidget(
        position: position,
        dismissOnTap: dismissOnTap,
        onDismiss: hide,
        child: child,
      ),
    );

    navigator.overlay!.insert(_overlayEntry!);

    // 取消之前的定时器
    _autoDismissTimer?.cancel();

    // 自动消失
    if (duration != null) {
      _autoDismissTimer = Timer(duration, () {
        hide();
      });
    }
  }

  /// 隐藏 Toast
  static void hide() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;

    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }
}

/// Toast 位置枚举
enum ToastPosition {
  top,
  center,
  bottom,
}

/// 自定义 Toast Widget
class _CustomToastWidget extends StatelessWidget {
  final Widget child;
  final ToastPosition position;
  final bool dismissOnTap;
  final VoidCallback onDismiss;

  const _CustomToastWidget({
    required this.child,
    required this.position,
    required this.dismissOnTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dismissOnTap ? onDismiss : null,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            _buildPositionedChild(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionedChild(BuildContext context) {
    switch (position) {
      case ToastPosition.top:
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: child,
        );
      case ToastPosition.center:
        return Center(child: child);
      case ToastPosition.bottom:
        return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom + 80,
          left: 16,
          right: 16,
          child: child,
        );
    }
  }
}

/// 文本 Toast Widget
class _TextToastWidget extends StatelessWidget {
  final String message;

  const _TextToastWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
