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
        builder: (context, state) => const DetailsPage(),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        builder: (context, state) => const SettingsPage(),
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
}
