import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/empty_state_widget.dart';
import '../../providers/notification_provider.dart';
import '../../../domain/entities/notification_entity.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(
                title: 'Notifications',
                trailing: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.refresh(notificationsProvider);
                  },
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            
            notificationsAsync.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primaryPlum))),
              error: (error, _) => SliverFillRemaining(child: Center(child: Text('Error: $error'))),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      icon: Icons.notifications_off_outlined,
                      title: 'All caught up!',
                      message: 'You have no new notifications. We\'ll let you know when there\'s an update.',
                      actionLabel: 'Refresh',
                      onActionPressed: () {
                        HapticFeedback.lightImpact();
                        ref.refresh(notificationsProvider);
                      },
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notif = notifications[index];
                        final displayData = _getDisplayData(notif.notificationType);
                        final timeFormatted = DateFormat('MMM d, h:mm a').format(notif.createdAt.toLocal());
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: displayData.color.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(displayData.icon, color: displayData.color, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif.title,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                            ),
                                          ),
                                          Text(
                                            timeFormatted,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        notif.message,
                                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1),
                        );
                      },
                      childCount: notifications.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ({IconData icon, Color color}) _getDisplayData(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return (icon: Icons.calendar_today, color: AppColors.success);
      case 'system':
        return (icon: Icons.info, color: Colors.blue);
      case 'lab':
        return (icon: Icons.folder_shared, color: AppColors.primaryPlum);
      case 'reminder':
        return (icon: Icons.medication, color: AppColors.primaryPink);
      default:
        return (icon: Icons.notifications, color: Colors.grey);
    }
  }
}
