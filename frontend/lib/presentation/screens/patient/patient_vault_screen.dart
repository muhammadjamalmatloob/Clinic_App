import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class PatientVaultScreen extends StatelessWidget {
  const PatientVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile & Settings coming soon!')),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pill Tracker Section
            _buildSectionHeader('Medication Tracker', Icons.medication),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPillTile('Iron Supplements', '1 Pill • After Breakfast', true),
                    const Divider(),
                    _buildPillTile('Calcium', '1 Pill • After Dinner', false),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Lab Reports & PDFs
            _buildSectionHeader('Digital Records', Icons.folder_shared),
            const SizedBox(height: 16),
            
            _buildRecordCard(context, 'Blood Test Report', 'Sept 15, 2026', Icons.science),
            const SizedBox(height: 12),
            _buildRecordCard(context, 'Ultrasound Scan', 'Aug 22, 2026', Icons.monitor_heart),
            const SizedBox(height: 12),
            _buildRecordCard(context, 'General Prescription', 'Aug 10, 2026', Icons.description),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryPlum),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPillTile(String name, String time, bool taken) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: taken ? AppColors.success.withOpacity(0.1) : AppColors.primaryPeach.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          taken ? Icons.check_circle : Icons.access_time_filled,
          color: taken ? AppColors.success : AppColors.primaryPeach,
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(time),
      trailing: taken 
          ? const Text('Taken', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))
          : ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPlum,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Take', style: TextStyle(color: AppColors.white)),
            ),
    );
  }

  Widget _buildRecordCard(BuildContext context, String title, String date, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: AppColors.primaryPlum),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Generating PDF for $title...')),
            );
          },
        ),
      ),
    );
  }
}
