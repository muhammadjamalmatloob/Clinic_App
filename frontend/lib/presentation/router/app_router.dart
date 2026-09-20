import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/patient/patient_dashboard.dart';
import '../screens/staff/staff_dashboard.dart';

final GoRouter appRouter = GoRouter(
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
    GoRoute(
      path: '/patient_dashboard',
      builder: (context, state) => const PatientDashboard(),
    ),
    GoRoute(
      path: '/staff_dashboard',
      builder: (context, state) => const StaffDashboard(),
    ),
  ],
);
