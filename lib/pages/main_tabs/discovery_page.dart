import 'package:flutter/material.dart';
import '../../core/widgets/base_page.dart';
import '../../core/widgets/custom_app_bar.dart';

import '../../shared/app_text_style.dart';

import '../../core/widgets/custom_alert.dart';
import '../../core/utils/loading_util.dart';
import '../../core/utils/toast_util.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: const CustomAppBar(
        title: '发现',
        showBackButton: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '发现页面内容',
              style: AppTextStyle.getStyle(
                fontFamily: 'Roboto',
                fontSize: 18,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                LoadingUtil.show();
                Future.delayed(const Duration(seconds: 2), () {
                  LoadingUtil.hide();
                });
              },
              child: const Text('测试 Loading (2秒后自动关闭)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                CustomAlert.showCustomDialog(
                  blurAmount: 5,
                  child: Builder(
                    builder: (dialogContext) => Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 60),
                          const SizedBox(height: 16),
                          const Text(
                            '通用容器弹窗',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '这个弹窗的 UI 完全由传入的 child 决定，CustomAlert 只负责遮罩和边距。',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: const Text('知道了'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: const Text('显示通用容器 Dialog'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                CustomAlert.showCustomBottom(
                  child: Builder(
                    builder: (sheetContext) => Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey)),
                            ),
                            child: const Text(
                              '选择操作',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.share),
                                title: const Text('分享'),
                                onTap: () => Navigator.of(sheetContext).pop(),
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text('删除', style: TextStyle(color: Colors.red)),
                                onTap: () => Navigator.of(sheetContext).pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: const Text('显示自定义 BottomSheet'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // 测试超长内容
                CustomAlert.showCustomBottom(
                  child: Builder(
                    builder: (sheetContext) => Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey)),
                            ),
                            child: const Text(
                              '超长内容测试',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '这是一个很长的内容测试，用来验证 BottomSheet 在内容超出屏幕高度时的表现。'
                              '内容会自动滚动，并且最大高度不会超过屏幕减去状态栏的高度。',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '更多内容...',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          for (int i = 1; i <= 20; i++)
                            ListTile(
                              leading: Icon(Icons.list),
                              title: Text('列表项 $i'),
                              subtitle: Text('这是第 $i 个列表项的描述信息'),
                              onTap: () => Navigator.of(sheetContext).pop(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  fixedHeight: 500,  // 固定高度500像素
                  blurAmount: 5.0,
                  onDismissed: () {
                    debugPrint('超长内容 BottomSheet 已关闭');
                  },
                );
              },
              child: const Text('测试超长内容 BottomSheet'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // 测试纯列表内容
                CustomAlert.showCustomBottom(
                  child: Builder(
                    builder: (sheetContext) => Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey)),
                            ),
                            child: const Text(
                              '纯列表测试',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 400,
                            child: ListView.builder(
                              itemCount: 50,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Icon(Icons.list),
                                  title: Text('列表项 ${index + 1}'),
                                  subtitle: Text('这是第 ${index + 1} 个列表项'),
                                  onTap: () => Navigator.of(sheetContext).pop(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // fixedHeight: 450,  // 固定高度450像素
                  onDismissed: () {
                    debugPrint('纯列表 BottomSheet 已关闭');
                  },
                );
              },
              child: const Text('测试纯列表 BottomSheet'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ToastUtil.show('这是一条普通消息'),
              child: const Text('Toast - 普通消息'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ToastUtil.show(
                '自定义持续时间 3秒',
                duration: const Duration(seconds: 3),
              ),
              child: const Text('Toast - 自定义时间'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ToastUtil.showCustom(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 40),
                      SizedBox(height: 12),
                      Text('自定义 Widget Toast', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              child: const Text('Toast - 自定义Widget'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ToastUtil.showCustom(
                position: ToastPosition.top,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '顶部成功提示',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              child: const Text('Toast - 顶部自定义'),
            ),
          ],
        ),
      ),
    );
  }
}
