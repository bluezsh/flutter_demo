import 'package:flutter/material.dart';
import '../../app/router/app_router.dart' show navigatorKey;

class LoadingUtil {
  LoadingUtil._();

  static OverlayEntry? _overlayEntry;

  static bool _isShowing = false;

  /// 显示 Loading
  static void show() {
    final navigator = navigatorKey.currentState;
    if (_isShowing || navigator == null) return;
    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => const _LoadingWidget(),
    );

    navigator.overlay!.insert(_overlayEntry!);
  }

  /// 隐藏 Loading
  static void hide() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}
