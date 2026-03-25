import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router/app_routes.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Start Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is the first page after startup.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go(AppRoute.home.path);
              },
              child: const Text('跳转到菜单主页面'),
            ),
          ],
        ),
      ),
    );
  }
}