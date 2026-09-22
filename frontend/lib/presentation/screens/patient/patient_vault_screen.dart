import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/empty_state_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../../domain/entities/prescription_entity.dart';

class PatientVaultScreen extends ConsumerStatefulWidget {
  const PatientVaultScreen({super.key});

  @override
  ConsumerState<PatientVaultScreen> createState() => _PatientVaultScreenState();
}

class _PatientVaultScreenState extends ConsumerState<PatientVaultScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    final prescriptionsAsync = ref.watch(patientPrescriptionsProvider(user.id));
    final medicalRecordsAsync = ref.watch(patientMedicalRecordsProvider(user.id));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(patientPrescriptionsProvider(user.id));
            ref.invalidate(patientMedicalRecordsProvider(user.id));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: AppHeader(
                  title: 'Medical Vault',
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.invalidate(patientPrescriptionsProvider(user.id));
                      ref.invalidate(patientMedicalRecordsProvider(user.id));
                    },
                  ),
                ),
              ),
              
              prescriptionsAsync.when(
                data: (prescriptions) {
                  return medicalRecordsAsync.when(
                    data: (records) {
                      if (prescriptions.isEmpty && records.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyStateWidget(
                            icon: Icons.folder_open,
                            title: 'Vault is empty',
                            message: 'Your medical records, prescriptions, and lab reports will appear here.',
                            actionLabel: 'Refresh',
                            onActionPressed: () {
                              ref.invalidate(patientPrescriptionsProvider(user.id));
                            },
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            if (prescriptions.isNotEmpty) ...[
                              _buildSectionHeader('Digital Prescriptions', Icons.medication).animate().fadeIn().slideX(begin: -0.1),
                              const SizedBox(height: 16),
                              ...prescriptions.map((p) => _buildPrescriptionCard(p)).toList(),
                              const SizedBox(height: 32),
                            ],
                            
                            if (records.isNotEmpty) ...[
                              _buildSectionHeader('Medical Records', Icons.folder_shared).animate().fadeIn().slideX(begin: -0.1),
                              const SizedBox(height: 16),
                              ...records.map((r) => _buildRecordCard(context, r.title, r.recordDate, Icons.description)).toList(),
                            ],
                            const SizedBox(height: 120), // For bottom nav spacing
                          ]),
                        ),
                      );
                    },
                    loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => SliverFillRemaining(child: Center(child: Text("Error: $e"))),
                  );
                },
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverFillRemaining(child: Center(child: Text("Error: $e"))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionEntity prescription) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text('Prescription • ${prescription.issuedAt.split('T')[0]}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPlum)),
        subtitle: Text('${prescription.items.length} medications', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primaryPlum.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.description, color: AppColors.primaryPlum),
        ),
        children: prescription.items.map((item) {
          return ListTile(
            title: Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${item.dosage} • ${item.frequency} for ${item.duration}\n${item.instructions ?? ""}'),
            isThreeLine: true,
          );
        }).toList(),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryPlum.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryPlum, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(BuildContext context, String title, String date, IconData icon) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryPink),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPlum)),
        subtitle: Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: AppColors.primaryPlum),
          onPressed: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading $title...')));
            PdfGenerator.generateAndPrintMedicalRecord(title, date, 'Aisha Khan');
          },
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening $title...')));
        },
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
