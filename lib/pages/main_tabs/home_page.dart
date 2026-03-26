import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/base_page.dart';
import '../../core/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_routes.dart';
import '../../app/router/cubit/router_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: const CustomAppBar(
        title: '首页',
        showBackButton: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('这是首页内容'),
            const SizedBox(height: 20),
            BlocBuilder<RouterCubit, RouterState>(
              builder: (context, state) {
                return Text('当前路由路径: ${state.currentPath}');
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => context.push(AppRoute.details.path),
              child: const Text('去详情页'),
            ),
          ],
        ),
      ),
    );
  }
}
