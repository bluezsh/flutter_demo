import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;
  final TextStyle? titleStyle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.height = 56.0,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? Theme.of(context).primaryColor;
    final TextStyle effectiveTitleStyle = titleStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        );

    return Container(
      color: effectiveBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black12,
                width: 0.5,
              ),
            ),
          ),
          child: Stack(
            children: [
              // 居中的标题
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56), // 为左右预留空间，防止标题过长重叠
                  child: Text(
                    title,
                    style: effectiveTitleStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // 左侧返回键或自定义 leading
              Align(
                alignment: Alignment.centerLeft,
                child: leading ??
                    (showBackButton && Navigator.of(context).canPop()
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        : null),
              ),
              // 右侧操作栏
              if (actions != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
