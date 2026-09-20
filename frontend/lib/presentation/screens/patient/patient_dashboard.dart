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
        title: const Text('Rukhsana Gynae Clinic'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile & Settings coming soon!')),
              );
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryPlum,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 24),
              
              // Currently Serving Card
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      AppStrings.currentlyServing,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    currentServingAsync.when(
                      data: (token) => Text(
                        token?.tokenNumber.toString() ?? '--',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(color: Colors.white),
                      error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
                    ),
                  ],
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
                    return ElevatedButton.icon(
                      onPressed: () {
                        ref.read(queueRepositoryProvider).requestToken(
                          user?.id ?? 'unknown',
                          user?.name ?? 'Unknown',
                        );
                      },
                      icon: const Icon(Icons.confirmation_num),
                      label: const Text(AppStrings.requestToken, style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primaryPlum,
                      ),
                    );
                  }

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                              color: AppColors.primaryPlum,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Estimated Wait', style: TextStyle(fontSize: 16)),
                              Text(
                                '${myToken.estimatedWaitTimeMinutes} mins',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primaryPink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status', style: TextStyle(fontSize: 16)),
                              Chip(
                                label: Text(
                                  myToken.status.name.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              
              const SizedBox(height: 32),
              // Emergency SOS Button
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling Clinic Emergency...')),
                  );
                },
                icon: const Icon(Icons.emergency, color: AppColors.error),
                label: const Text('EMERGENCY SOS', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
