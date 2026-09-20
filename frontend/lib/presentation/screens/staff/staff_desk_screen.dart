import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';

class StaffDeskScreen extends StatelessWidget {
  const StaffDeskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor's Desk"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Calendar View Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Schedule",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    context.push('/staff/calendar');
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('View Calendar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Unified view mockup
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildScheduleItem('09:00 AM', 'Fatima Ali', 'Advance Booking', AppColors.primaryPlum),
                  const Divider(height: 1),
                  _buildScheduleItem('09:15 AM', 'Ayesha Khan', 'Token #1 (Walk-in)', AppColors.primaryPeach),
                  const Divider(height: 1),
                  _buildScheduleItem('09:30 AM', 'Sana Tariq', 'Token #2 (Walk-in)', AppColors.primaryPeach),
                  const Divider(height: 1),
                  _buildScheduleItem('09:45 AM', 'Zainab Ahmed', 'Advance Booking', AppColors.primaryPlum),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              "Digital Prescription",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Digital Prescription Form Mockup
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Patient Name / ID',
                        prefixIcon: const Icon(Icons.person_search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Medication & Dosage',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Prescription Saved & Sent to Pharmacy')),
                          );
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Send to Pharmacy & Patient Vault'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primaryPlum,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80), // Padding to prevent overlap with bottom nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String time, String name, String type, Color color) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(type),
      trailing: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
