class ServiceEntity {
  final String id;
  final String name;
  final String? description;
  final int durationMinutes;
  final double? priceMin;
  final double? priceMax;

  ServiceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.durationMinutes,
    this.priceMin,
    this.priceMax,
  });

  factory ServiceEntity.fromJson(Map<String, dynamic> json) {
    return ServiceEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      priceMin: json['price_min'] != null ? double.parse(json['price_min'].toString()) : null,
      priceMax: json['price_max'] != null ? double.parse(json['price_max'].toString()) : null,
    );
  }
}

