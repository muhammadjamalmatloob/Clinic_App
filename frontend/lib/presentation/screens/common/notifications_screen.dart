import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/empty_state_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _hasNotifications = false;

  final _mockNotifications = [
    {'title': 'Appointment Confirmed', 'message': 'Your appointment for General Health is confirmed for tomorrow at 10:00 AM.', 'time': '2m ago', 'icon': Icons.check_circle, 'color': AppColors.success},
    {'title': 'Dr. Rukhsana Update', 'message': 'Dr. Rukhsana is currently running 15 minutes late. Thank you for your patience.', 'time': '1h ago', 'icon': Icons.info, 'color': Colors.blue},
    {'title': 'Lab Results Ready', 'message': 'Your latest ultrasound scan results are now available in your Medical Vault.', 'time': 'Yesterday', 'icon': Icons.folder_shared, 'color': AppColors.primaryPlum},
    {'title': 'Reminder', 'message': 'Don\'t forget to take your prescribed Iron Supplements after breakfast.', 'time': 'Yesterday', 'icon': Icons.medication, 'color': AppColors.primaryPink},
  ];

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
                title: 'Notifications',
                trailing: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _hasNotifications = !_hasNotifications);
                  },
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            
            if (!_hasNotifications)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateWidget(
                  icon: Icons.notifications_off_outlined,
                  title: 'All caught up!',
                  message: 'You have no new notifications. We\'ll let you know when there\'s an update.',
                  actionLabel: 'Load Demo Notifications',
                  onActionPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _hasNotifications = true);
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notif = _mockNotifications[index];
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
                                  color: (notif['color'] as Color).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(notif['icon'] as IconData, color: notif['color'] as Color, size: 24),
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
                                            notif['title'] as String,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                          ),
                                        ),
                                        Text(
                                          notif['time'] as String,
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notif['message'] as String,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1),
                      );
                    },
                    childCount: _mockNotifications.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
