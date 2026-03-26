import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainTabPage extends StatelessWidget {
  const MainTabPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildCustomBottomBar(context),
    );
  }

  Widget _buildCustomBottomBar(BuildContext context) {
    final Color activeColor = Theme.of(context).primaryColor;
    const Color inactiveColor = Colors.grey;

    return Container(
      height: 60 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12), // 0.05 * 255 ≈ 12
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildNavItem(0, Icons.home_rounded, '首页', activeColor, inactiveColor),
            _buildNavItem(1, Icons.explore_rounded, '发现', activeColor, inactiveColor),
            _buildNavItem(2, Icons.person_rounded, '我的', activeColor, inactiveColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    Color inactiveColor,
  ) {
    final bool isSelected = navigationShell.currentIndex == index;
    final Color color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: () => _onTap(index),
        splashColor: activeColor.withAlpha(25), // 0.1 * 255 ≈ 25
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
