import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/patient/patient_dashboard.dart';
import '../screens/patient/patient_services_screen.dart';
import '../screens/patient/patient_vault_screen.dart';
import '../screens/patient/patient_shell.dart';
import '../screens/staff/staff_dashboard.dart';
import '../screens/staff/staff_shell.dart';
import '../screens/common/coming_soon_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _patientShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'patientShell');
final GlobalKey<NavigatorState> _staffShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'staffShell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    // PATIENT APP ROUTES
    ShellRoute(
      navigatorKey: _patientShellNavigatorKey,
      builder: (context, state, child) => PatientShell(child: child),
      routes: [
        GoRoute(
          path: '/patient',
          builder: (context, state) => const PatientDashboard(),
        ),
        GoRoute(
          path: '/patient/services',
          builder: (context, state) => const PatientServicesScreen(),
        ),
        GoRoute(
          path: '/patient/vault',
          builder: (context, state) => const PatientVaultScreen(),
        ),
      ],
    ),
    // STAFF APP ROUTES
    ShellRoute(
      navigatorKey: _staffShellNavigatorKey,
      builder: (context, state, child) => StaffShell(child: child),
      routes: [
        GoRoute(
          path: '/staff',
          builder: (context, state) => const StaffDashboard(),
        ),
        GoRoute(
          path: '/staff/desk',
          builder: (context, state) => const ComingSoonScreen(title: 'Doctor Desk'),
        ),
        GoRoute(
          path: '/staff/analytics',
          builder: (context, state) => const ComingSoonScreen(title: 'Pharmacy & Analytics'),
        ),
      ],
    ),
  ],
);
