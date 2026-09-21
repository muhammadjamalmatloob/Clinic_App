import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import 'package:go_router/go_router.dart';

class PostVisitFeedbackScreen extends StatelessWidget {
  const PostVisitFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: Column(
          children: [
            AppHeader(
              title: 'Post-Visit Feedback',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How was your last visit?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryPlum),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStar(Icons.star, AppColors.warning),
                _buildStar(Icons.star, AppColors.warning),
                _buildStar(Icons.star, AppColors.warning),
                _buildStar(Icons.star, AppColors.warning),
                _buildStar(Icons.star_border, Colors.grey),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your experience with Dr. Rukhsana...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback Submitted!')));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPlum,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(IconData icon, Color color) {
    return Icon(icon, color: color, size: 40);
  }
}
