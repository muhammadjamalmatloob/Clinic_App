import 'package:flutter/material.dart';

class AppColors {
  // Brand colors matched to website
  static const Color primaryPlum = Color(0xFF6A2E59); // Deep plum/purple from website
  static const Color primaryPink = Color(0xFFF55B77); // Pink part of gradient
  static const Color primaryPeach = Color(0xFFFCA56E); // Peach/Orange part of gradient
  
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF8F9FA); // Off-white for background
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF757575);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  // Reusable Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPink, primaryPeach],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
