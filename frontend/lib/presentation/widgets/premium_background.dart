import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Color
        Container(color: AppColors.background),
        
        // Animated Mesh Gradient Orbs
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPink.withValues(alpha: 0.15),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .move(duration: 8.seconds, curve: Curves.easeInOut, begin: const Offset(0, 0), end: const Offset(100, 50))
          .scale(duration: 10.seconds, curve: Curves.easeInOut, begin: const Offset(1, 1), end: const Offset(1.5, 1.5)),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPlum.withValues(alpha: 0.1),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .move(duration: 12.seconds, curve: Curves.easeInOut, begin: const Offset(0, 0), end: const Offset(-100, -100))
          .scale(duration: 8.seconds, curve: Curves.easeInOut, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
        ),
        Positioned(
          top: 200,
          right: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C3AED).withValues(alpha: 0.08), // Violet
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .move(duration: 15.seconds, curve: Curves.easeInOut, begin: const Offset(0, 0), end: const Offset(-50, 100))
          .scale(duration: 12.seconds, curve: Curves.easeInOut, begin: const Offset(1.5, 1.5), end: const Offset(1, 1)),
        ),

        // Glass Blur Overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),

        // Content
        Positioned.fill(child: child),
      ],
    );
  }
}
