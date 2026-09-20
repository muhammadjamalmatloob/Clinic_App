import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/patient/patient_dashboard.dart';
import '../screens/patient/patient_services_screen.dart';
import '../screens/patient/patient_vault_screen.dart';
import '../screens/patient/patient_shell.dart';
import '../screens/staff/staff_dashboard.dart';
import '../screens/staff/staff_desk_screen.dart';
import '../screens/staff/staff_analytics_screen.dart';
import '../screens/staff/staff_shell.dart';
import '../screens/common/profile_settings_screen.dart';
import '../screens/common/manage_dependents_screen.dart';
import '../screens/common/vaccination_tracker_screen.dart';
import '../screens/common/health_blog_screen.dart';
import '../screens/common/post_visit_feedback_screen.dart';
import '../screens/patient/book_appointment_screen.dart';
import '../screens/patient/cost_estimator_screen.dart';
import '../screens/patient/ai_symptom_checker_screen.dart';
import '../screens/staff/add_admin_screen.dart';
import '../screens/staff/broadcast_announcement_screen.dart';
import '../screens/staff/calendar_schedule_screen.dart';

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
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileSettingsScreen(),
    ),
    GoRoute(
      path: '/profile/dependents',
      builder: (context, state) => const ManageDependentsScreen(),
    ),
    GoRoute(
      path: '/profile/vaccination',
      builder: (context, state) => const VaccinationTrackerScreen(),
    ),
    GoRoute(
      path: '/profile/health_blog',
      builder: (context, state) => const HealthBlogScreen(),
    ),
    GoRoute(
      path: '/profile/feedback',
      builder: (context, state) => const PostVisitFeedbackScreen(),
    ),
    GoRoute(
      path: '/profile/add_admin',
      builder: (context, state) => const AddAdminScreen(),
    ),
    GoRoute(
      path: '/staff/broadcast',
      builder: (context, state) => const BroadcastAnnouncementScreen(),
    ),
    GoRoute(
      path: '/staff/calendar',
      builder: (context, state) => const CalendarScheduleScreen(),
    ),
    GoRoute(
      path: '/patient/book',
      builder: (context, state) => const BookAppointmentScreen(),
    ),
    GoRoute(
      path: '/patient/cost',
      builder: (context, state) => const CostEstimatorScreen(),
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
          path: '/patient/ai',
          builder: (context, state) => const AiSymptomCheckerScreen(),
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
          builder: (context, state) => const StaffDeskScreen(),
        ),
        GoRoute(
          path: '/staff/analytics',
          builder: (context, state) => const StaffAnalyticsScreen(),
        ),
      ],
    ),
  ],
);
