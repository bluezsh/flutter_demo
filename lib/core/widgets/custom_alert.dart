import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/router/app_router.dart';

class CustomAlert {
  /// 显示自定义对话框 (通用容器)
  ///
  /// [child] 弹窗显示的 Widget 内容
  /// [horizontalMargin] 弹窗距离屏幕左右的边距，默认 20.0
  /// [barrierDismissible] 点击外部是否可以关闭，默认 true
  /// [barrierColor] 遮罩颜色，默认黑色带 0.6 透明度
  /// [blurAmount] 遮罩模糊度，默认 0.0
  /// [onDismissed] 弹窗关闭时的回调函数
  static Future<T?> showCustomDialog<T>({
    required Widget child,
    double horizontalMargin = 20.0,
    bool barrierDismissible = true,
    Color barrierColor = const Color(
      0x99000000,
    ), // Colors.black.withValues(alpha: 0.6)
    double blurAmount = 0.0,
    VoidCallback? onDismissed,
  }) {
    return showDialog<T>(
      context: navigatorKey.currentContext!,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useRootNavigator: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            child: blurAmount > 0
                ? BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurAmount,
                      sigmaY: blurAmount,
                    ),
                    child: child,
                  )
                : child,
          ),
        );
      },
    ).then((result) {
      onDismissed?.call();
      return result;
    });
  }

  /// 显示自定义 BottomSheet
  ///
  /// [child] BottomSheet 显示的 Widget 内容
  /// [barrierDismissible] 点击外部是否可以关闭，默认 true
  /// [barrierColor] 遮罩颜色，默认黑色带 0.6 透明度
  /// [blurAmount] 背景模糊度，默认 0.0
  /// [onDismissed] BottomSheet 关闭时的回调函数
  /// [fixedHeight] 固定高度，如果未指定则完全自适应高度
  ///
  /// 使用示例：
  /// ```dart
  /// // 自适应高度
  /// CustomAlert.showCustomBottom(
  ///   child: Container(
  ///     child: Column(
  ///       children: [
  ///         Text('标题'),
  ///         Text('内容'),
  ///       ],
  ///     ),
  ///   ),
  /// );
  ///
  /// // 固定高度
  /// CustomAlert.showCustomBottom(
  ///   child: Container(
  ///     child: ListView.builder(
  ///       itemCount: 50,
  ///       itemBuilder: (context, index) => ListTile(
  ///         title: Text('项目 $index'),
  ///       ),
  ///     ),
  ///   ),
  ///   fixedHeight: 400,
  ///   blurAmount: 5.0,
  ///   onDismissed: () {
  ///     debugPrint('BottomSheet 已关闭');
  ///   },
  /// );
  /// ```
  static Future<T?> showCustomBottom<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color barrierColor = const Color(0x99000000),
    double blurAmount = 0.0,
    VoidCallback? onDismissed,
    double? fixedHeight,
  }) {
    return showModalBottomSheet<T>(
      context: navigatorKey.currentContext!,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      barrierColor: barrierColor,
      useRootNavigator: true,
      builder: (context) {
        final content = Container(
          constraints: BoxConstraints(
            minHeight: 0,
            maxHeight: fixedHeight ?? double.infinity,
          ),
          child: SingleChildScrollView(child: child),
        );

        final wrappedContent = blurAmount > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurAmount,
                  sigmaY: blurAmount,
                ),
                child: content,
              )
            : content;

        return wrappedContent;
      },
    ).then((result) {
      onDismissed?.call();
      return result;
    });
  }
}
