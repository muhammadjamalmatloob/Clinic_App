import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';

class PatientShell extends StatelessWidget {
  final Widget child;
  const PatientShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Calculate selected index based on current location
    int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int idx) => _onItemTapped(idx, context),
        selectedItemColor: AppColors.primaryPlum,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.queue), label: 'Live Queue'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI Bot'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_shared), label: 'Vault'),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/patient/services')) return 1;
    if (location.startsWith('/patient/ai')) return 2;
    if (location.startsWith('/patient/vault')) return 3;
    return 0; // Default to Live Queue
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/patient');
        break;
      case 1:
        context.go('/patient/services');
        break;
      case 2:
        context.go('/patient/ai');
        break;
      case 3:
        context.go('/patient/vault');
        break;
    }
  }
}
