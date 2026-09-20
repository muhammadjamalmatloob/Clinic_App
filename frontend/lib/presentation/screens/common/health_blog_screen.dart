import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class HealthBlogScreen extends StatelessWidget {
  const HealthBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health & Wellness Blog'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildBlogCard('Healthy Eating During Pregnancy', 'Nutrition tips for a healthy journey.', 'Oct 1, 2026'),
          _buildBlogCard('Postpartum Recovery', 'What to expect and how to take care of yourself.', 'Sep 25, 2026'),
          _buildBlogCard('Childhood Milestones', 'Tracking your baby\'s first year of development.', 'Sep 10, 2026'),
        ],
      ),
    );
  }

  Widget _buildBlogCard(String title, String summary, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
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
