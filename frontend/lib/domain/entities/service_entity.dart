class ServiceEntity {
  final String id;
  final String name;
  final String? description;
  final int durationMinutes;

  ServiceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.durationMinutes,
  });

  factory ServiceEntity.fromJson(Map<String, dynamic> json) {
    return ServiceEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int,
    );
  }
}
