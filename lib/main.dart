import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/app/router/app_router.dart';
import 'package:flutter_demo/core/utils/status_bar_util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: routerCubit,
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        builder: (context, child) {
          // Set the status bar color and brightness
          StatusBarUtil.setColor(Colors.blue, brightness: Brightness.light);
          return child!;
        },
      ),
    );
  }
}
