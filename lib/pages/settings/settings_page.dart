import 'package:flutter/material.dart';
import '../../core/widgets/base_page.dart';
import '../../core/widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePage(
      appBar: CustomAppBar(title: '设置'),
      body: Center(
        child: Text('这是二级页面：设置页内容'),
      ),
    );
  }
}
