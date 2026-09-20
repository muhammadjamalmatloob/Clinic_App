import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/clinic.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.local_hospital, size: 100, color: AppColors.primaryPink),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primaryPurple),
          ],
        ),
      ),
    );
  }
}
