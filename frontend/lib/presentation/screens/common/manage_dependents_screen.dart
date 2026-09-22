import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dependent_provider.dart';
import '../../../presentation/widgets/custom_toast.dart';

class ManageDependentsScreen extends ConsumerStatefulWidget {
  const ManageDependentsScreen({super.key});

  @override
  ConsumerState<ManageDependentsScreen> createState() => _ManageDependentsScreenState();
}

class _ManageDependentsScreenState extends ConsumerState<ManageDependentsScreen> {
  void _showAddDependentForm(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String? selectedRelationship;
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
                  const Text('Add New Dependent', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryPlum)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Relationship',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Son', child: Text('Son')),
                      DropdownMenuItem(value: 'Daughter', child: Text('Daughter')),
                      DropdownMenuItem(value: 'Spouse', child: Text('Spouse')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      selectedRelationship = val;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Age (Years)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : () async {
                      if (nameController.text.trim().isEmpty || selectedRelationship == null) {
                        CustomToast.showError(context, 'Name and Relationship are required');
                        return;
                      }

                      setStateModal(() => isSubmitting = true);
                      
                      try {
                        final user = ref.read(authProvider);
                        await ref.read(dependentRepositoryProvider).createDependent(
                          guardianId: user!.id,
                          fullName: nameController.text.trim(),
                          relationshipType: selectedRelationship!,
                          age: int.tryParse(ageController.text.trim()),
                        );
                        
                        // Refresh the list
                        ref.invalidate(patientDependentsProvider);
                        
                        if (mounted) {
                          Navigator.pop(context);
                          CustomToast.showSuccess(context, 'Dependent added successfully');
                        }
                      } catch (e) {
                        if (mounted) {
                          CustomToast.showError(context, 'Failed to add dependent: $e');
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
                        : const Text('Save Dependent'),
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

  void _deleteDependent(String id) async {
    try {
      await ref.read(dependentRepositoryProvider).deleteDependent(id);
      ref.invalidate(patientDependentsProvider);
      if (mounted) {
        CustomToast.showSuccess(context, 'Dependent deleted');
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, 'Failed to delete dependent');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dependentsAsync = ref.watch(patientDependentsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: Column(
          children: [
            AppHeader(
              title: 'Manage Dependents',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            Expanded(
              child: dependentsAsync.when(
                data: (dependents) {
                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (dependents.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: Text('No dependents found.', style: TextStyle(color: Colors.white70))),
                        ),
                      ...dependents.map((dep) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GlassCard(
                            padding: EdgeInsets.zero,
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primaryPink,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(dep.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${dep.relationshipType}${dep.age != null ? ' - ${dep.age} years old' : ''}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDependent(dep.id),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddDependentForm(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Dependent', style: TextStyle(fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPlum,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
