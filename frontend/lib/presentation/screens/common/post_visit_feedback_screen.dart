import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class PostVisitFeedbackScreen extends StatelessWidget {
  const PostVisitFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post-Visit Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  Widget _buildStar(IconData icon, Color color) {
    return Icon(icon, color: color, size: 40);
  }
}
