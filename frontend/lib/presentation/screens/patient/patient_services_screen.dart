import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../providers/appointment_provider.dart';

class PatientServicesScreen extends ConsumerWidget {
  const PatientServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
              const SizedBox(height: 24),

              // Action Buttons
              Column(
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
                  const SizedBox(height: 12),
                  
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
                  const SizedBox(height: 12),
                  
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
              const SizedBox(height: 32),
              
              // Services List
              ref.watch(servicesProvider).when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryPlum)),
                error: (error, _) => Center(child: Text('Error loading services: $error')),
                data: (services) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: services.length + 1, // +1 for bottom padding
                    itemBuilder: (context, index) {
                      if (index == services.length) {
                        return const SizedBox(height: 120);
                      }
                      final service = services[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildServiceCard(
                          context,
                          service.name,
                          service.description ?? 'Available today',
                          Icons.local_hospital,
                          const Color(0xFFF0FDF4),
                          const Color(0xFF16A34A),
                        ),
                      ).animate().fadeIn(delay: (400 + (index * 100)).ms).slideY(begin: 0.1);
                    },
                  );
                },
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
