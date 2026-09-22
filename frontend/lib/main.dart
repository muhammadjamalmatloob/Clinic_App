import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/strings.dart';
import 'presentation/router/app_router.dart';

import 'presentation/providers/auth_provider.dart';
import 'core/local_db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await DatabaseHelper.instance.database;

  final container = ProviderContainer();
  
  final hasSeenOnboardingStr = await DatabaseHelper.instance.getAppSetting('has_seen_onboarding');
  final hasSeenOnboarding = hasSeenOnboardingStr == 'true';
  container.read(onboardingSeenProvider.notifier).state = hasSeenOnboarding;

  await container.read(authProvider.notifier).loadSession();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Deep link received: $uri');
      if (uri.scheme == 'clinicapp' && uri.host == 'reset-callback') {
        // We received a password reset callback!
        // We need to parse the access token from the hash fragment
        // Supabase puts access_token=... in the fragment.
        final fragment = uri.fragment;
        if (fragment.isNotEmpty) {
          final params = Uri.splitQueryString(fragment);
          final accessToken = params['access_token'];
          if (accessToken != null) {
            // We got the token! We should probably save it and navigate to the new password screen.
            // Wait, our backend handles update. We can just navigate to the new password screen!
            final router = ref.read(routerProvider);
            router.go('/new-password');
          }
        } else {
          // If no fragment, just go anyway to be safe (maybe the URL is formatted differently)
          final router = ref.read(routerProvider);
          router.go('/new-password');
        }
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
