import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/base_page.dart';
import '../../core/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_routes.dart';
import '../../app/router/cubit/router_cubit.dart';
import '../../core/utils/log_util.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: const CustomAppBar(
        title: '首页',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
            const Text('日志功能测试', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => LogUtil.log('这是一条普通文本日志'),
                  child: const Text('文本日志'),
                ),
                ElevatedButton(
                  onPressed: () => LogUtil.log(
                    {'id': 100, 'name': '测试对象', 'active': true, 'tags': ['flutter', 'demo']},
                    format: LogFormat.json,
                  ),
                  child: const Text('JSON 对象'),
                ),
                ElevatedButton(
                  onPressed: () => LogUtil.log(
                    '{"code": 200, "data": {"list": [1, 2, 3]}}',
                    format: LogFormat.json,
                  ),
                  child: const Text('JSON 字符串'),
                ),
                ElevatedButton(
                  onPressed: () => LogUtil.log(
                    '这不是一个有效的 JSON 字符串',
                    format: LogFormat.json,
                  ),
                  child: const Text('非法 JSON'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final longText = List.generate(100, (i) => '这是第$i行长文本测试内容').join('\n');
                    LogUtil.log(longText);
                  },
                  child: const Text('超长文本'),
                ),
              ],
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
