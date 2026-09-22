class AnnouncementEntity {
  final String id;
  final String createdById;
  final String message;
  final String audience;
  final String? expiresAt;

  AnnouncementEntity({
    required this.id,
    required this.createdById,
    required this.message,
    required this.audience,
    this.expiresAt,
  });

  factory AnnouncementEntity.fromJson(Map<String, dynamic> json) {
    return AnnouncementEntity(
      id: json['id'] as String,
      createdById: json['created_by_id'] as String,
      message: json['message'] as String,
      audience: json['audience'] as String,
      expiresAt: json['expires_at'] as String?,
    );
  }
}
