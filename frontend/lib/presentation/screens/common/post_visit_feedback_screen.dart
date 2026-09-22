import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../../presentation/widgets/custom_toast.dart';

class PostVisitFeedbackScreen extends ConsumerStatefulWidget {
  const PostVisitFeedbackScreen({super.key});

  @override
  ConsumerState<PostVisitFeedbackScreen> createState() => _PostVisitFeedbackScreenState();
}

class _PostVisitFeedbackScreenState extends ConsumerState<PostVisitFeedbackScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  void _submitFeedback() async {
    final user = ref.read(authProvider);
    if (user == null) return;

    setState(() => _isSubmitting = true);
    
    try {
      await ref.read(feedbackRepositoryProvider).createFeedback(
        patientId: user.id,
        rating: _rating,
        comment: _commentController.text.trim(),
      );
      if (mounted) {
        CustomToast.showSuccess(context, 'Feedback Submitted! Thank you.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, 'Failed to submit feedback');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

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
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          return GestureDetector(
                            onTap: () => setState(() => _rating = starValue),
                            child: Icon(
                              starValue <= _rating ? Icons.star : Icons.star_border,
                              color: starValue <= _rating ? AppColors.warning : Colors.grey,
                              size: 40,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _commentController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Share your experience...',
                          hintStyle: const TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPlum,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}
