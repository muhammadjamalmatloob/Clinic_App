import '../../core/network/api_client.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/repositories/i_article_repository.dart';

class ArticleRepository implements IArticleRepository {
  final ApiClient apiClient;

  ArticleRepository(this.apiClient);

  @override
  Future<List<ArticleEntity>> getArticles() async {
    final response = await apiClient.dio.get('/articles/');
    final List<dynamic> data = response.data;
    return data.map((json) => ArticleEntity.fromJson(json)).toList();
  }
}
