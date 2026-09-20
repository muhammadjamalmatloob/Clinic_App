import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';

class PatientServicesScreen extends StatelessWidget {
  const PatientServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services & Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.push('/profile');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
            ),
            const SizedBox(height: 24),

            // Services Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildServiceCard(context, 'General Health', Icons.favorite),
                _buildServiceCard(context, "Women's Care", Icons.pregnant_woman),
                _buildServiceCard(context, 'Child Care', Icons.child_care),
                _buildServiceCard(context, 'Ultrasound', Icons.monitor_heart),
              ],
            ),

            const SizedBox(height: 32),
            
            // Advance Appointment Booking
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_month),
              label: const Text('Book Advance Appointment', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primaryPlum,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),
            
            // Procedure Cost Estimator
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calculate, color: AppColors.primaryPlum),
              label: const Text('Procedure Cost Estimator', style: TextStyle(fontSize: 16, color: AppColors.primaryPlum)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryPlum),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 16),

            // Symptom Checker
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.medical_information, color: AppColors.primaryPink),
              label: const Text('AI Symptom Checker', style: TextStyle(fontSize: 16, color: AppColors.primaryPink)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryPink),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData iconData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return AppColors.primaryGradient.createShader(bounds);
                },
                child: Icon(iconData, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
