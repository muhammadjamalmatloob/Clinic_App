import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';

class StaffShell extends StatelessWidget {
  final Widget child;
  const StaffShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int idx) => _onItemTapped(idx, context),
        selectedItemColor: AppColors.primaryPlum,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.control_camera), label: 'Control'),
          BottomNavigationBarItem(icon: Icon(Icons.desk), label: 'Doctor Desk'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
        ],
      ),
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
