import 'package:flutter/material.dart';

class AppTextStyle {
  /// 封装通用文本样式
  ///
  /// [fontFamily] 字体类型 (必填)
  /// [fontSize] 字体大小 (必填)
  /// [color] 字体颜色 (必填)
  /// [fontWeight] 字体粗细 (可选)
  /// [fontStyle] 字体样式 (可选)
  /// [letterSpacing] 字符间距 (可选)
  /// [wordSpacing] 单词间距 (可选)
  /// [height] 行高 (可选)
  /// [decoration] 装饰线 (可选)
  /// [overflow] 溢出处理 (可选)
  static TextStyle getStyle({
    required String fontFamily,
    required double fontSize,
    required Color color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    TextOverflow? overflow,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      overflow: overflow,
      shadows: shadows,
    );
  }

  /// 预设常用样式示例 (可选，可根据项目需求增加)
  static TextStyle bodyMain({
    double fontSize = 14,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return getStyle(
      fontFamily: 'Roboto', // 默认字体，可根据实际项目修改
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
}
