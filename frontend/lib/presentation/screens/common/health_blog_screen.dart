import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import 'package:go_router/go_router.dart';
import '../../providers/article_provider.dart';
import 'package:intl/intl.dart';

class HealthBlogScreen extends ConsumerWidget {
  const HealthBlogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider);

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
              child: articlesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryPlum)),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (articles) {
                  if (articles.isEmpty) {
                    return const Center(child: Text('No articles available at the moment.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      final dateFormatted = DateFormat('MMM d, yyyy').format(article.createdAt);
                      return _buildBlogCard(article.title, article.summary, dateFormatted);
                    },
                  );
                },
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

