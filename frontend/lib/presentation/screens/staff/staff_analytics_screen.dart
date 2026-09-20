import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/pdf_generator.dart';

class StaffAnalyticsScreen extends StatelessWidget {
  const StaffAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacy & Analytics"),
      ),
      body: SingleChildScrollView(
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
            Row(
              children: [
                _buildStatCard('Total Patients', '42', Icons.people, AppColors.primaryPlum),
                const SizedBox(width: 16),
                _buildStatCard('Avg Wait', '14m', Icons.timer, AppColors.primaryPeach),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('Completion', '85%', Icons.check_circle, AppColors.success),
                const SizedBox(width: 16),
                _buildStatCard('Pending', '6', Icons.pending, AppColors.warning),
              ],
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

            const SizedBox(height: 32),
            const Text(
              "Pharmacy Sync",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Pharmacy Sync list
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPharmacyOrder('Ayesha Khan', 'Pending Prep', true),
                  const Divider(height: 1),
                  _buildPharmacyOrder('Sana Tariq', 'Ready for Pickup', false),
                ],
              ),
            )
          ],
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

  Widget _buildPharmacyOrder(String name, String status, bool isPending) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.background,
        child: Icon(Icons.medication, color: AppColors.primaryPlum),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(status),
      trailing: isPending 
          ? ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              child: const Text('Mark Ready'),
            )
          : const Icon(Icons.check_circle, color: AppColors.success),
    );
  }
}
