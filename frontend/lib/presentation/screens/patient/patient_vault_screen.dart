import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/empty_state_widget.dart';

class PatientVaultScreen extends StatefulWidget {
  const PatientVaultScreen({super.key});

  @override
  State<PatientVaultScreen> createState() => _PatientVaultScreenState();
}

class _PatientVaultScreenState extends State<PatientVaultScreen> {
  bool _hasRecords = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(
                title: 'Medical Vault',
                trailing: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _hasRecords = !_hasRecords);
                  },
                ),
              ),
            ),
            
            if (!_hasRecords)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateWidget(
                  icon: Icons.folder_open,
                  title: 'Vault is empty',
                  message: 'Your medical records, prescriptions, and lab reports will appear here.',
                  actionLabel: 'Load Demo Records',
                  onActionPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _hasRecords = true);
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Pill Tracker Section
                    _buildSectionHeader('Medication Tracker', Icons.medication).animate().fadeIn().slideX(begin: -0.1),
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _buildPillTile('Iron Supplements', '1 Pill • After Breakfast', true),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Divider(height: 1),
                          ),
                          _buildPillTile('Calcium', '1 Pill • After Dinner', false),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 32),
                    
                    // Lab Reports & PDFs
                    _buildSectionHeader('Digital Records', Icons.folder_shared).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 16),
                    
                    _buildRecordCard(context, 'Blood Test Report', 'Sept 15, 2026', Icons.science).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                    const SizedBox(height: 12),
                    _buildRecordCard(context, 'Ultrasound Scan', 'Aug 22, 2026', Icons.monitor_heart).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                    const SizedBox(height: 12),
                    _buildRecordCard(context, 'General Prescription', 'Aug 10, 2026', Icons.description).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 120), // For bottom nav spacing
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
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

  Widget _buildPillTile(String name, String time, bool taken) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: taken ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.medication,
            color: taken ? AppColors.success : Colors.grey,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPlum)),
        subtitle: Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Icon(
          taken ? Icons.check_circle : Icons.circle_outlined,
          color: taken ? AppColors.success : Colors.grey,
          size: 28,
        ),
      ),
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
    );
  }
}
