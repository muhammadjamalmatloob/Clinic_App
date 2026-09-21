class DependentEntity {
  final String id;
  final String guardianId;
  final String fullName;
  final String relationshipType;
  final int? age;

  DependentEntity({
    required this.id,
    required this.guardianId,
    required this.fullName,
    required this.relationshipType,
    this.age,
  });

  factory DependentEntity.fromJson(Map<String, dynamic> json) {
    return DependentEntity(
      id: json['id'] as String,
      guardianId: json['guardian_id'] as String,
      fullName: json['full_name'] as String,
      relationshipType: json['relationship_type'] as String,
      age: json['age'] as int?,
    );
  }
}
