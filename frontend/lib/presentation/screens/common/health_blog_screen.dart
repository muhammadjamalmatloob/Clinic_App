import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import 'package:go_router/go_router.dart';

class HealthBlogScreen extends StatelessWidget {
  const HealthBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: Column(
          children: [
            AppHeader(
              title: 'Health & Wellness Blog',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
          _buildBlogCard('Healthy Eating During Pregnancy', 'Nutrition tips for a healthy journey.', 'Oct 1, 2026'),
          _buildBlogCard('Postpartum Recovery', 'What to expect and how to take care of yourself.', 'Sep 25, 2026'),
          _buildBlogCard('Childhood Milestones', 'Tracking your baby\'s first year of development.', 'Sep 10, 2026'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogCard(String title, String summary, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPlum)),
            const SizedBox(height: 8),
            Text(summary, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Text('Read More', style: TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
