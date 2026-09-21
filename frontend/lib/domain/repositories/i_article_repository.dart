import '../entities/article_entity.dart';

abstract class IArticleRepository {
  Future<List<ArticleEntity>> getArticles();
}
