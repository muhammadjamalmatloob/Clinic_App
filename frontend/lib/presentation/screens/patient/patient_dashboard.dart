import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/queue_provider.dart';
import '../../../domain/entities/token_entity.dart';

class PatientDashboard extends ConsumerWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final currentServingAsync = ref.watch(currentServingTokenProvider);
    final queueAsync = ref.watch(queueStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.patientDashboard),
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
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hello, ${user?.name ?? 'Patient'}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              
              // Currently Serving Card
              Card(
                color: AppColors.primaryPurple,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        AppStrings.currentlyServing,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      currentServingAsync.when(
                        data: (token) => Text(
                          token?.tokenNumber.toString() ?? '--',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const CircularProgressIndicator(color: Colors.white),
                        error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // My Token Section
              queueAsync.when(
                data: (tokens) {
                  final myToken = tokens.cast<TokenEntity?>().firstWhere(
                    (t) => t?.patientId == user?.id,
                    orElse: () => null,
                  );

                  if (myToken == null) {
                    return ElevatedButton(
                      onPressed: () {
                        ref.read(queueRepositoryProvider).requestToken(
                          user?.id ?? 'unknown',
                          user?.name ?? 'Unknown',
                        );
                      },
                      child: const Text(AppStrings.requestToken),
                    );
                  }

                  return Card(
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text(
                            AppStrings.yourToken,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${myToken.tokenNumber}',
                            style: const TextStyle(
                              color: AppColors.primaryPink,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(AppStrings.estimatedWaitTime),
                              Text(
                                '${myToken.estimatedWaitTimeMinutes} mins',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status'),
                              Chip(
                                label: Text(
                                  myToken.status.name.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                backgroundColor: myToken.status == TokenStatus.serving 
                                    ? AppColors.success 
                                    : AppColors.warning,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Failed to load queue')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
