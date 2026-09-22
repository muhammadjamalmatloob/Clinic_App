import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/medical_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patients_provider.dart';

import '../../widgets/premium_background.dart';
import '../../widgets/app_header.dart';
import '../../../presentation/widgets/custom_toast.dart';

class StaffDeskScreen extends ConsumerStatefulWidget {
  const StaffDeskScreen({super.key});

  @override
  ConsumerState<StaffDeskScreen> createState() => _StaffDeskScreenState();
}

class _StaffDeskScreenState extends ConsumerState<StaffDeskScreen> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final appointmentsAsync = ref.watch(appointmentsProvider(dateStr));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(appointmentsProvider(dateStr));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: AppHeader(
                  title: "Doctor's Desk",
                  subtitle: "Manage consultations",
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
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
              
              appointmentsAsync.when(
                data: (appointments) {
                  if (appointments.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text("No appointments scheduled for today.")),
                      ),
                    );
                  }
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appointments.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final apt = appointments[index];
                        return _buildScheduleItem(
                          apt.appointmentTime,
                          apt.patientName != null 
                              ? 'Patient: ${apt.patientName}' 
                              : 'Patient ID: ${apt.patientId.substring(0, 8)}',
                          apt.status.toUpperCase(),
                          AppColors.primaryPlum,
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Failed to load: $err')),
              ),

              const SizedBox(height: 32),
              const Text(
                "Digital Prescription",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Digital Prescription Form
              const _PrescriptionForm(),
              const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

class _PrescriptionForm extends ConsumerStatefulWidget {
  const _PrescriptionForm();

  @override
  ConsumerState<_PrescriptionForm> createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends ConsumerState<_PrescriptionForm> {
  String? _selectedPatientId;
  final _notesController = TextEditingController();
  
  final List<Map<String, TextEditingController>> _items = [];
  bool _isLoading = false;

  void _addItem() {
    setState(() {
      _items.add({
        'medicineName': TextEditingController(),
        'dosage': TextEditingController(),
        'frequency': TextEditingController(),
        'duration': TextEditingController(),
        'instructions': TextEditingController(),
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _submit() async {
    if (_selectedPatientId == null || _items.isEmpty) {
      CustomToast.showError(context, 'Please select a patient and add items');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider);
      
      final itemsData = _items.map((controllers) {
        return {
          'medicine_name': controllers['medicineName']!.text,
          'dosage': controllers['dosage']!.text,
          'frequency': controllers['frequency']!.text,
          'duration': controllers['duration']!.text,
          if (controllers['instructions']!.text.isNotEmpty) 'instructions': controllers['instructions']!.text,
        };
      }).toList();

      await ref.read(medicalRepositoryProvider).createPrescription(
        patientId: _selectedPatientId!,
        doctorId: user!.id,
        notes: _notesController.text.trim(),
        items: itemsData,
      );

      if (mounted) {
        CustomToast.showSuccess(context, 'Prescription saved successfully');
        setState(() {
          _selectedPatientId = null;
          _notesController.clear();
          _items.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, 'Failed to save prescription: $e');
        // Show the error dialog so it doesn't get missed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Submission Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
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
    final patientsAsync = ref.watch(patientsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            patientsAsync.when(
              data: (patients) {
                return DropdownMenu<String>(
                  width: MediaQuery.of(context).size.width - 64,
                  hintText: 'Select Patient',
                  leadingIcon: const Icon(Icons.person_search),
                  onSelected: (value) {
                    setState(() {
                      _selectedPatientId = value;
                    });
                  },
                  dropdownMenuEntries: patients.map((p) {
                    return DropdownMenuEntry<String>(
                      value: p.id,
                      label: '${p.name} (${p.phoneNumber})',
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Failed to load patients: $err'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Doctor Notes (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Medications:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final controllers = _items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: AppColors.primaryPeach.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controllers['medicineName'],
                                decoration: const InputDecoration(labelText: 'Medicine Name', isDense: true),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controllers['dosage'],
                                decoration: const InputDecoration(labelText: 'Dosage (e.g. 500mg)', isDense: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: controllers['frequency'],
                                decoration: const InputDecoration(labelText: 'Freq (e.g. 1x daily)', isDense: true),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controllers['duration'],
                                decoration: const InputDecoration(labelText: 'Duration (e.g. 5 days)', isDense: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: controllers['instructions'],
                                decoration: const InputDecoration(labelText: 'Instructions', isDense: true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            TextButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Medication'),
            ),
            const SizedBox(height: 16),
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                  label: const Text('Send to Pharmacy & Patient Vault'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primaryPlum,
                    foregroundColor: Colors.white,
                  ),
                )
          ],
        ),
      ),
    );
  }
}
