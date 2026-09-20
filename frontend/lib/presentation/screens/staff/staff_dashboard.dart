import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/queue_provider.dart';
import '../../../domain/entities/token_entity.dart';

class StaffDashboard extends ConsumerWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueStreamProvider);
    final repo = ref.read(queueRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.staffDashboard),
        backgroundColor: AppColors.primaryPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/auth');
            },
          )
        ],
      ),
      body: queueAsync.when(
        data: (tokens) {
          final waitingTokens = tokens.where((t) => t.status == TokenStatus.waiting).toList();
          final servingToken = tokens.cast<TokenEntity?>().firstWhere(
            (t) => t?.status == TokenStatus.serving,
            orElse: () => null,
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Control Panel
                Card(
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Serving: ${servingToken?.tokenNumber ?? '--'}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPink,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  repo.callNextPatient();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Call Next Patient'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  repo.toggleQueuePauseStatus();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Pause Queue'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Waiting List
                Text(
                  'Waiting Patients (${waitingTokens.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: waitingTokens.length,
                    itemBuilder: (context, index) {
                      final token = waitingTokens[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryPink.withOpacity(0.2),
                          child: Text('${token.tokenNumber}', style: const TextStyle(color: AppColors.primaryPink)),
                        ),
                        title: Text(token.patientName),
                        subtitle: Text('Wait time: ~${token.estimatedWaitTimeMinutes} mins'),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error),
                          onPressed: () {
                            // Skip patient functionality
                          },
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
        error: (_, __) => const Center(child: Text('Error loading queue')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Manual token entry for walk-ins
          repo.requestToken('walkin_${DateTime.now().millisecondsSinceEpoch}', 'Walk-in Patient');
        },
        backgroundColor: AppColors.primaryPurple,
        icon: const Icon(Icons.add),
        label: const Text('Add Walk-in'),
      ),
    );
  }
}
