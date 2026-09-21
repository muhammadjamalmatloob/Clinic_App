import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/repositories/i_article_repository.dart';
import '../../data/repositories/article_repository.dart';
import 'api_client_provider.dart';

final articleRepositoryProvider = Provider<IArticleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ArticleRepository(apiClient);
});

final articlesProvider = FutureProvider<List<ArticleEntity>>((ref) {
  return ref.watch(articleRepositoryProvider).getArticles();
});
