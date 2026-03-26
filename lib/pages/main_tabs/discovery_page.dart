import 'package:flutter/material.dart';
import '../../core/widgets/base_page.dart';
import '../../core/widgets/custom_app_bar.dart';

import '../../shared/app_text_style.dart';

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
        child: Text(
          '发现页面内容',
          style: AppTextStyle.getStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
