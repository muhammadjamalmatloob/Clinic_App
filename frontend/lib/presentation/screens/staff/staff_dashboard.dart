import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../domain/entities/token_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/queue_provider.dart';

class StaffDashboard extends ConsumerWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueStreamProvider);
    final currentServingAsync = ref.watch(currentServingTokenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/profile');
            },
          )
        ],
      ),
      body: queueAsync.when(
        data: (tokens) {
          final waitingTokens = tokens.where((t) => t.status == TokenStatus.waiting).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Broadcast Announcements
                Card(
                  color: AppColors.primaryPeach.withOpacity(0.2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.campaign, color: AppColors.primaryPlum),
                    title: const Text('Broadcast Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Push notification to all waiting patients'),
                    trailing: const Icon(Icons.send, color: AppColors.primaryPlum),
                    onTap: () {
                      context.push('/staff/broadcast');
                    },
                  ),
                ),
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
                    if (token == null) return const Text('No patient currently serving.');
                    return Card(
                      color: AppColors.primaryPlum,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text('Token ${token.tokenNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(token.patientName, style: const TextStyle(color: Colors.white70)),
                        trailing: ElevatedButton(
                          onPressed: () {
                            ref.read(queueRepositoryProvider).completeCurrentPatient();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPeach),
                          child: const Text('Complete', style: TextStyle(color: Colors.black87)),
                        ),
                      ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading current token'),
                ),
                const SizedBox(height: 24),

                // Waiting List
                const Text('Waiting Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: waitingTokens.isEmpty
                      ? const Center(child: Text('No patients waiting'))
                      : ListView.builder(
                          itemCount: waitingTokens.length,
                          itemBuilder: (context, index) {
                            final token = waitingTokens[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.background,
                                  child: Text('${token.tokenNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                title: Text(token.patientName),
                                subtitle: Text('Est. Wait: ${token.estimatedWaitTimeMinutes} mins'),
                                trailing: const Icon(Icons.more_vert),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load queue')),
      ),
    );
  }
}
