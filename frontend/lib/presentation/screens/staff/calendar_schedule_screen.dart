import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../providers/appointment_provider.dart';

class CalendarScheduleScreen extends ConsumerStatefulWidget {
  const CalendarScheduleScreen({super.key});

  @override
  ConsumerState<CalendarScheduleScreen> createState() => _CalendarScheduleScreenState();
}

class _CalendarScheduleScreenState extends ConsumerState<CalendarScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final appointmentsAsync = ref.watch(appointmentsProvider(dateStr));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Appointments for $dateStr",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            appointmentsAsync.when(
              data: (appointments) {
                if (appointments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text("No appointments scheduled for this date.")),
                  );
                }
                return Column(
                  children: appointments.map((apt) => _buildAppointmentCard(
                    apt.appointmentTime,
                    'Patient ID: ${apt.patientId.substring(0, 8)}...',
                    'Status: ${apt.status.toUpperCase()}',
                    AppColors.primaryPlum,
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Failed to load: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(String time, String title, String subtitle, Color color) {
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
