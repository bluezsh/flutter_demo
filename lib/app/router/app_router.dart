import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app.dart';
import '../../pages/main_tabs/main_tab_page.dart';
import '../../pages/main_tabs/home_page.dart';
import '../../pages/main_tabs/discovery_page.dart';
import '../../pages/main_tabs/profile_page.dart';
import '../../pages/details/details_page.dart';
import '../../pages/settings/settings_page.dart';
import 'app_routes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

/// 页面跳转动画类型
enum _PageTransitionType {
  slideRight,
  slideLeft,
  slideTop,
  slideBottom,
  fadeIn;

  Duration get defaultDuration {
    switch (this) {
      case _PageTransitionType.slideRight:
      case _PageTransitionType.slideLeft:
      case _PageTransitionType.slideTop:
      case _PageTransitionType.slideBottom:
        return const Duration(milliseconds: 350);
      case _PageTransitionType.fadeIn:
        return const Duration(milliseconds: 200);
    }
  }
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoute.app.path,
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: AppRoute.app.path,
        builder: (context, state) => const App(),
      ),
      GoRoute(
        path: AppRoute.details.path,
        pageBuilder: (context, state) => _buildPage(
          child: const DetailsPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        pageBuilder: (context, state) => _buildPage(
          child: const SettingsPage(),
          key: state.pageKey,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.discovery.path,
                builder: (context, state) => const DiscoveryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.profile.path,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// 构建带动画的页面
  static CustomTransitionPage<T> _buildPage<T>({
    required Widget child,
    required LocalKey key,
    _PageTransitionType type = _PageTransitionType.slideRight,
    Duration? duration,
  }) {
    final effectiveDuration = duration ?? type.defaultDuration;

    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: effectiveDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case _PageTransitionType.slideRight:
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          case _PageTransitionType.slideLeft:
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          case _PageTransitionType.slideTop:
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(0.0, -1.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          case _PageTransitionType.slideBottom:
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          case _PageTransitionType.fadeIn:
            return FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: Curves.easeIn),
              ),
              child: child,
            );
        }
      },
    );
  }
}
