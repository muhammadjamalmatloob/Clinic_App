import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';

import '../../widgets/floating_bottom_nav.dart';

class StaffShell extends StatelessWidget {
  final Widget child;
  const StaffShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentIndex: currentIndex,
              onTap: (int idx) => _onItemTapped(idx, context),
              items: const [
                FloatingNavItem(icon: Icons.control_camera, label: 'Control'),
                FloatingNavItem(icon: Icons.desk, label: 'Desk'),
                FloatingNavItem(icon: Icons.analytics, label: 'Analytics'),
              ],
            ),
          ),
        ],
      ),
      extendBody: true,
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/staff/desk')) return 1;
    if (location.startsWith('/staff/analytics')) return 2;
    return 0; 
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/staff');
        break;
      case 1:
        context.go('/staff/desk');
        break;
      case 2:
        context.go('/staff/analytics');
        break;
    }
  }
}
