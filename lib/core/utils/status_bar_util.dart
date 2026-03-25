import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBarUtil {
  /// 设置状态栏颜色
  ///
  /// [color] 状态栏的颜色.
  /// [brightness] 状态栏图标的亮度.
  static void setColor(Color color, {Brightness brightness = Brightness.dark}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: brightness,
        statusBarBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ));
    });
  }
}
