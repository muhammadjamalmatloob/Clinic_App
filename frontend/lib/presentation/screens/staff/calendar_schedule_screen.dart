import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class CalendarScheduleScreen extends StatelessWidget {
  const CalendarScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Schedule Calendar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Calendar Mockup
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                        const Text('September 2026', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Mock days
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                          .map((d) => Text(d, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 30,
                      itemBuilder: (context, index) {
                        final isToday = index + 1 == 20; // Mock today as 20th
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.primaryPlum : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isToday ? Colors.white : AppColors.textPrimary,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              "Appointments for Sept 20",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildAppointmentCard('09:00 AM', 'Fatima Ali', 'Advance Booking', AppColors.primaryPlum),
            _buildAppointmentCard('09:45 AM', 'Zainab Ahmed', 'Advance Booking', AppColors.primaryPlum),
            _buildAppointmentCard('10:30 AM', 'Hira Nasir', 'Consultation', AppColors.primaryPeach),
            _buildAppointmentCard('11:00 AM', 'Maria Qasim', 'Ultrasound', AppColors.primaryPeach),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(String time, String name, String type, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(time, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(type),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
