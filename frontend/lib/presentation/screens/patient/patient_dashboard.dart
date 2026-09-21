import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_animate/flutter_animate.dart';

import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';

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
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: AppHeader(
                  title: user?.name ?? 'Patient',
                  subtitle: 'Good morning,',
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white),
                        onPressed: () => context.push('/notifications'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => context.push('/profile'),
                      ),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
              
              // Currently Serving Card
              GlassCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                         .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5))
                         .fade(begin: 0.5, end: 1),
                        const SizedBox(width: 8),
                        const Text(
                          'LIVE CLINIC STATUS',
                          style: TextStyle(
                            color: AppColors.primaryPink,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.currentlyServing,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    currentServingAsync.when(
                      data: (token) => Text(
                        token?.tokenNumber.toString() ?? '--',
                        style: const TextStyle(
                          color: AppColors.primaryPlum,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn().scale(),
                      loading: () => const CircularProgressIndicator(color: AppColors.primaryPlum),
                      error: (_, __) => const Text('Error', style: TextStyle(color: AppColors.primaryPlum)),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
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
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
                  }

                  return GlassCard(
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(height: 1, color: AppColors.background),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimated Wait', style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
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
                            const Text('Status', style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: myToken.status == TokenStatus.serving ? Colors.green.shade50 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: myToken.status == TokenStatus.serving ? Colors.green.shade200 : Colors.orange.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8, 
                                    height: 8, 
                                    decoration: BoxDecoration(
                                      color: myToken.status == TokenStatus.serving ? Colors.green : Colors.orange, 
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    myToken.status.name.toUpperCase(),
                                    style: TextStyle(
                                      color: myToken.status == TokenStatus.serving ? Colors.green.shade700 : Colors.orange.shade700, 
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Failed to load queue')),
              ),
              
              const SizedBox(height: 32),
              
              // Quick Actions
              const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon')));
                      },
                      child: const GlassCard(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Icon(Icons.calendar_month, color: AppColors.primaryPink, size: 28),
                            SizedBox(height: 8),
                            Text('Book Now', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon')));
                      },
                      child: const GlassCard(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Icon(Icons.video_call, color: AppColors.primaryPlum, size: 28),
                            SizedBox(height: 8),
                            Text('Telehealth', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.go('/patient/ai');
                      },
                      child: const GlassCard(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Icon(Icons.smart_toy, color: Colors.blueAccent, size: 28),
                            SizedBox(height: 8),
                            Text('Ask AI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Health Tip Banner
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryPlum.withValues(alpha: 0.8), AppColors.primaryPink.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryPlum.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.water_drop, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Health Tip of the Day', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Text('Stay hydrated! Aim for 8 glasses of water today.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 32),

              // Emergency SOS Button
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.emergency, color: AppColors.error),
                label: const Text('EMERGENCY SOS', style: TextStyle(fontSize: 16, color: AppColors.error, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.error, width: 2),
                  backgroundColor: AppColors.error.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ).animate().fadeIn(delay: 700.ms).shake(delay: 2.seconds),
              const SizedBox(height: 120), // For bottom nav
            ]),
          ),
        ),
      ],
    ),
  ),
),
);
}
}
