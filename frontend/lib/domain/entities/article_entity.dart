class ArticleEntity {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String authorId;
  final DateTime createdAt;

  ArticleEntity({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.authorId,
    required this.createdAt,
  });

  factory ArticleEntity.fromJson(Map<String, dynamic> json) {
    return ArticleEntity(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      authorId: json['author_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
