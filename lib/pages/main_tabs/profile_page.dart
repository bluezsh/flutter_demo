import 'package:flutter/material.dart';
import '../../core/widgets/base_page.dart';
import '../../core/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_routes.dart';

import '../../shared/app_text_style.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: CustomAppBar(
        title: '个人中心',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoute.settings.path),
          ),
        ],
      ),
      body: Center(
        child: Text(
          '个人中心内容',
          style: AppTextStyle.getStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}
