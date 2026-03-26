import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/base_page.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../app/router/app_routes.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: const CustomAppBar(title: '详情页'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('这是二级页面：详情页内容'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go(AppRoute.discovery.path),
              child: const Text('跳转到发现 (第二个菜单)'),
            ),
          ],
        ),
      ),
    );
  }
}
