import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../domain/entities/token_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/queue_provider.dart';
import '../../providers/patients_provider.dart';

class StaffDashboard extends ConsumerWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueStreamProvider);
    final currentServingAsync = ref.watch(currentServingTokenProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(
                title: 'Control Desk',
                subtitle: 'Clinic Admin',
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => context.push('/profile'),
                ),
                height: 140,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 20),
              ),
            ),
          SliverToBoxAdapter(
            child: queueAsync.when(
              data: (tokens) {
                final waitingTokens = tokens.where((t) => t.status == TokenStatus.waiting).toList();

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                // Broadcast Announcements
                GlassCard(
                  padding: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.campaign, color: AppColors.primaryPlum),
                    title: const Text('Broadcast Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Push notification to all waiting patients'),
                    trailing: const Icon(Icons.send, color: AppColors.primaryPlum),
                    onTap: () {
                      context.push('/staff/broadcast');
                    },
                  ),
                ).animate().fadeIn().slideX(begin: 0.1),
                const SizedBox(height: 24),
                
                // Control Panel
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: waitingTokens.isNotEmpty
                            ? () {
                                ref.read(queueRepositoryProvider).callNextPatient();
                              }
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Call Next'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Pause logic
                        },
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause Queue'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Currently Serving
                const Text('Currently Serving', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                currentServingAsync.when(
                  data: (token) {
                    if (token == null) return const GlassCard(child: Text('No patient currently serving.', style: TextStyle(color: AppColors.textSecondary)));
                    return GlassCard(
                      child: ListTile(
                        title: Text('Token ${token.tokenNumber}', style: const TextStyle(color: AppColors.primaryPlum, fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text(token.patientName, style: const TextStyle(color: AppColors.textSecondary)),
                        trailing: ElevatedButton(
                          onPressed: () {
                            ref.read(queueRepositoryProvider).completeCurrentPatient();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPlum,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Complete', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading current token'),
                ),
                const SizedBox(height: 24),

                // Waiting List
                const Text('Waiting Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                  waitingTokens.isEmpty
                      ? const Center(child: Text('No patients waiting'))
                      : Consumer(
                          builder: (context, ref, child) {
                            final patientsAsync = ref.watch(patientsProvider);
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: waitingTokens.length,
                              itemBuilder: (context, index) {
                                final token = waitingTokens[index];
                                final patientName = patientsAsync.maybeWhen(
                                  data: (patients) {
                                    final patient = patients.cast().firstWhere(
                                      (p) => p.id == token.patientId,
                                      orElse: () => null,
                                    );
                                    return patient?.name ?? 'Unknown Patient';
                                  },
                                  orElse: () => 'Loading...',
                                );

                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.background,
                                      child: Text('${token.tokenNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    title: Text(patientName),
                                    subtitle: Text('Est. Wait: ${token.estimatedWaitTimeMinutes} mins'),
                                    trailing: const Icon(Icons.more_vert),
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Failed to load queue: $e')),
      ),
    ),
  ],
),
      ),
    );
  }
}
