import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../providers/clinic_provider.dart';

class StaffAnalyticsScreen extends ConsumerWidget {
  const StaffAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final analyticsAsync = ref.watch(dailyAnalyticsProvider(dateStr));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacy & Analytics"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyAnalyticsProvider(dateStr));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Daily Analytics",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Stats Grid
              analyticsAsync.when(
                data: (analytics) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          _buildStatCard('Total Patients', '${analytics.totalPatients}', Icons.people, AppColors.primaryPlum),
                          const SizedBox(width: 16),
                          _buildStatCard('Avg Wait', '${analytics.averageWaitMinutes.round()}m', Icons.timer, AppColors.primaryPeach),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard('Completion', '${(analytics.completionRate * 100).round()}%', Icons.check_circle, AppColors.success),
                          const SizedBox(width: 16),
                          _buildStatCard('Pending', '${analytics.pendingCount}', Icons.pending, AppColors.warning),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Failed to load analytics: $err')),
              ),

              const SizedBox(height: 24),
              
              // PDF Generation
              OutlinedButton.icon(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preparing Daily Summary PDF...')),
                  );
                  await PdfGenerator.generateAndPrintDailyReport();
                },
                icon: const Icon(Icons.picture_as_pdf, color: AppColors.primaryPlum),
                label: const Text('Export Daily Report (PDF)', style: TextStyle(color: AppColors.primaryPlum)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primaryPlum),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

