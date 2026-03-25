import 'package:flutter/material.dart';
import '../../core/widgets/base_page.dart';
import '../../core/widgets/custom_app_bar.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePage(
      appBar: CustomAppBar(title: '详情页'),
      body: Center(
        child: Text('这是二级页面：详情页内容'),
      ),
    );
  }
}
