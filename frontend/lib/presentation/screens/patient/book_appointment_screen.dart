import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../../domain/entities/service_entity.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  ServiceEntity? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  void _bookAppointment() async {
    if (_selectedService == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select service, date, and time')),
      );
      return;
    }

    final user = ref.read(authProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    
    try {
      final dateStr = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      final timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';
      
      await ref.read(appointmentRepositoryProvider).bookAppointment(
        patientId: user.id,
        serviceId: _selectedService!.id,
        date: dateStr,
        time: timeStr,
        reason: _reasonController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment Requested successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: Column(
          children: [
            AppHeader(
              title: 'Book Appointment',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Schedule your visit in advance',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPlum),
                      ),
                      const SizedBox(height: 24),
                      servicesAsync.when(
                        data: (services) {
                          return DropdownButtonFormField<ServiceEntity>(
                            decoration: InputDecoration(
                              labelText: 'Select Service',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.5),
                            ),
                            items: services.map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name),
                            )).toList(),
                            onChanged: (val) {
                              setState(() => _selectedService = val);
                            },
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Failed to load services'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: _selectedDate == null 
                            ? 'Select Date' 
                            : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                          suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryPlum),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 60)),
                          );
                          if (date != null) setState(() => _selectedDate = date);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: _selectedTime == null
                            ? 'Select Time'
                            : _selectedTime!.format(context),
                          suffixIcon: const Icon(Icons.access_time, color: AppColors.primaryPlum),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 9, minute: 0),
                          );
                          if (time != null) setState(() => _selectedTime = time);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _reasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Reason for Visit (Optional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _isLoading 
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _bookAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPlum,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Confirm Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
