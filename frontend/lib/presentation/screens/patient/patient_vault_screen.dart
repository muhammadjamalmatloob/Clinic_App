import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/pdf_generator.dart';

class PatientVaultScreen extends StatelessWidget {
  const PatientVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            pinned: true,
            title: const Text('Medical Vault', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: AppColors.textPrimary),
                onPressed: () {
                  context.push('/profile');
                },
              )
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Pill Tracker Section
                _buildSectionHeader('Medication Tracker', Icons.medication).animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade100, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPlum.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildPillTile('Iron Supplements', '1 Pill • After Breakfast', true),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Divider(height: 1),
                      ),
                      _buildPillTile('Calcium', '1 Pill • After Dinner', false),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 32),
                
                // Lab Reports & PDFs
                _buildSectionHeader('Digital Records', Icons.folder_shared).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                const SizedBox(height: 16),
                
                _buildRecordCard(context, 'Blood Test Report', 'Sept 15, 2026', Icons.science).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 12),
                _buildRecordCard(context, 'Ultrasound Scan', 'Aug 22, 2026', Icons.monitor_heart).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                const SizedBox(height: 12),
                _buildRecordCard(context, 'General Prescription', 'Aug 10, 2026', Icons.description).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 80), // For bottom nav spacing
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryPlum.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryPlum, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPillTile(String name, String time, bool taken) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: taken ? AppColors.success.withValues(alpha: 0.1) : AppColors.primaryPeach.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            taken ? Icons.check_circle : Icons.access_time_filled,
            color: taken ? AppColors.success : AppColors.primaryPeach,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(time, style: const TextStyle(fontSize: 13)),
        trailing: taken 
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Taken', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            : ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPlum,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Take', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, String title, String date, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPlum.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.primaryPink),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(date, style: const TextStyle(fontSize: 12)),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.primaryPlum, size: 20),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Preparing PDF for $title...')),
              );
              await PdfGenerator.generateAndPrintMedicalRecord(title, date, 'Patient User');
            },
          ),
        ),
      ),
    );
  }
}
