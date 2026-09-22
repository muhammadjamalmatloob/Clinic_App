import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../providers/dependent_provider.dart';
import '../../providers/vaccination_provider.dart';
import '../../../domain/entities/dependent_entity.dart';
import '../../../domain/entities/vaccination_entity.dart';
import '../../../presentation/widgets/custom_toast.dart';

class VaccinationTrackerScreen extends ConsumerStatefulWidget {
  const VaccinationTrackerScreen({super.key});

  @override
  ConsumerState<VaccinationTrackerScreen> createState() => _VaccinationTrackerScreenState();
}

class _VaccinationTrackerScreenState extends ConsumerState<VaccinationTrackerScreen> {
  String? _selectedDependentId;

  void _showAddVaccinationForm(BuildContext context, List<DependentEntity> dependents) {
    if (dependents.isEmpty) {
      CustomToast.showError(context, 'Please add a dependent first');
      return;
    }

    final nameController = TextEditingController();
    String? localSelectedDepId = _selectedDependentId ?? dependents.first.id;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Add Upcoming Vaccination', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryPlum)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: localSelectedDepId,
                    decoration: InputDecoration(
                      labelText: 'Dependent',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: dependents.map((dep) => DropdownMenuItem(value: dep.id, child: Text(dep.fullName))).toList(),
                    onChanged: (val) {
                      setStateModal(() => localSelectedDepId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Vaccine Name (e.g., Polio Booster)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : () async {
                      if (nameController.text.trim().isEmpty || localSelectedDepId == null) {
                        CustomToast.showError(context, 'All fields are required');
                        return;
                      }

                      setStateModal(() => isSubmitting = true);
                      
                      try {
                        // Due date defaults to 1 month from now for upcoming
                        final due = DateTime.now().add(const Duration(days: 30));
                        await ref.read(vaccinationRepositoryProvider).createVaccination(
                          dependentId: localSelectedDepId!,
                          vaccineName: nameController.text.trim(),
                          dueDate: due,
                          status: 'upcoming',
                        );
                        
                        ref.invalidate(dependentVaccinationsProvider(localSelectedDepId!));
                        
                        if (mounted) {
                          Navigator.pop(context);
                          CustomToast.showSuccess(context, 'Vaccination Added!');
                        }
                      } catch (e) {
                        if (mounted) {
                          CustomToast.showError(context, 'Failed to add vaccination');
                        }
                      } finally {
                        if (mounted) {
                          setStateModal(() => isSubmitting = false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPlum,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSubmitting 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Vaccination'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _markCompleted(String vaccinationId, String dependentId) async {
    try {
      await ref.read(vaccinationRepositoryProvider).markVaccinationCompleted(vaccinationId, DateTime.now());
      ref.invalidate(dependentVaccinationsProvider(dependentId));
      if (mounted) {
        CustomToast.showSuccess(context, 'Marked as Completed');
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, 'Failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dependentsAsync = ref.watch(patientDependentsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      floatingActionButton: dependentsAsync.whenOrNull(
        data: (deps) => FloatingActionButton(
          backgroundColor: AppColors.primaryPlum,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _showAddVaccinationForm(context, deps),
        ),
      ),
      body: PremiumBackground(
        child: Column(
          children: [
            AppHeader(
              title: 'Vaccination Tracker',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            Expanded(
              child: dependentsAsync.when(
                data: (dependents) {
                  if (dependents.isEmpty) {
                    return const Center(child: Text('Please add a dependent in Manage Dependents first.', style: TextStyle(color: Colors.white70)));
                  }

                  // Default to first dependent if none selected
                  if (_selectedDependentId == null && dependents.isNotEmpty) {
                    Future.microtask(() => setState(() => _selectedDependentId = dependents.first.id));
                  }

                  if (_selectedDependentId == null) return const SizedBox.shrink();

                  final vaccinationsAsync = ref.watch(dependentVaccinationsProvider(_selectedDependentId!));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedDependentId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: dependents.map((dep) => DropdownMenuItem(value: dep.id, child: Text(dep.fullName))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedDependentId = val);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: vaccinationsAsync.when(
                          data: (vaccinations) {
                            final upcoming = vaccinations.where((v) => v.status == 'upcoming').toList();
                            final past = vaccinations.where((v) => v.status == 'completed').toList();

                            return ListView(
                              padding: const EdgeInsets.all(16.0),
                              children: [
                                const Text('Upcoming Vaccinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPlum)),
                                const SizedBox(height: 16),
                                if (upcoming.isEmpty)
                                  const Padding(padding: EdgeInsets.only(bottom: 24.0), child: Text('No upcoming vaccinations.')),
                                ...upcoming.map((v) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: GlassCard(
                                    padding: EdgeInsets.zero,
                                    child: ListTile(
                                      leading: const Icon(Icons.vaccines, color: AppColors.warning),
                                      title: Text(v.vaccineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(v.dueDate != null ? 'Due: \${v.dueDate!.year}-\${v.dueDate!.month}-\${v.dueDate!.day}' : 'Upcoming'),
                                      trailing: ElevatedButton(
                                        onPressed: () => _markCompleted(v.id, v.dependentId),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryPlum,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Complete'),
                                      ),
                                    ),
                                  ),
                                )),
                                
                                const SizedBox(height: 24),
                                const Text('Past Vaccinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                const SizedBox(height: 16),
                                if (past.isEmpty)
                                  const Text('No past vaccinations.'),
                                ...past.map((v) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: GlassCard(
                                    padding: EdgeInsets.zero,
                                    child: ListTile(
                                      leading: const Icon(Icons.check_circle, color: AppColors.success),
                                      title: Text(v.vaccineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(v.completedDate != null ? 'Completed: \${v.completedDate!.year}-\${v.completedDate!.month}-\${v.completedDate!.day}' : 'Completed'),
                                    ),
                                  ),
                                )),
                              ],
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Failed to load: $e')),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load dependents: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
