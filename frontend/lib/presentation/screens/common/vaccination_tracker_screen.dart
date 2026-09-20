import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class VaccinationTrackerScreen extends StatelessWidget {
  const VaccinationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Upcoming Vaccinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPlum)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.vaccines, color: AppColors.warning),
              title: const Text('Polio Booster (Ali Ahmad)'),
              subtitle: const Text('Due: Oct 15, 2026'),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPlum,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Book'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Past Vaccinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.success),
              title: Text('Measles Vaccine (Ali Ahmad)'),
              subtitle: Text('Completed: Jan 10, 2025'),
            ),
          ),
        ],
      ),
    );
  }
}
