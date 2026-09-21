import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';

class PatientServicesScreen extends StatelessWidget {
  const PatientServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppHeader(
              title: 'Services & Booking',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              // Header
              Text(
                "We're Providing\nBest Services",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPlum,
                ),
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 16),

              // Action Buttons
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/patient/book');
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Book Advance Appointment', style: TextStyle(fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primaryPlum,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ).animate().fadeIn(delay: 100.ms).scale(),
                    
                    OutlinedButton.icon(
                      onPressed: () {
                        context.push('/patient/cost');
                      },
                      icon: const Icon(Icons.calculate, color: AppColors.primaryPlum),
                      label: const Text('Procedure Cost Estimator', style: TextStyle(fontSize: 15, color: AppColors.primaryPlum)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryPlum),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    
                    OutlinedButton.icon(
                      onPressed: () {
                        context.push('/patient/ai');
                      },
                      icon: const Icon(Icons.medical_information, color: AppColors.primaryPink),
                      label: const Text('AI Symptom Checker', style: TextStyle(fontSize: 15, color: AppColors.primaryPink)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryPink),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Services List
              Expanded(
                flex: 5,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  children: [
                    Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildServiceCard(context, 'General Health', 'Available today', Icons.favorite, const Color(0xFFFFF1F2), const Color(0xFFE11D48))).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                    Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildServiceCard(context, "Women's Care", 'Dr. Rukhsana', Icons.pregnant_woman, const Color(0xFFF5F3FF), const Color(0xFF7C3AED))).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                    Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildServiceCard(context, 'Child Care', 'Pediatrics', Icons.child_care, const Color(0xFFFFFBEB), const Color(0xFFD97706))).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                    Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildServiceCard(context, 'Ultrasound', 'Radiology', Icons.monitor_heart, const Color(0xFFF0FDF4), const Color(0xFF16A34A))).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                    const SizedBox(height: 120), // padding for floating bottom nav inside list
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
);
}

  Widget _buildServiceCard(BuildContext context, String title, String subtitle, IconData iconData, Color bgColor, Color iconColor) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 28, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
