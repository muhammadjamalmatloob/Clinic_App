class VaccinationEntity {
  final String id;
  final String dependentId;
  final String vaccineName;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final String status; // 'upcoming' or 'completed'

  VaccinationEntity({
    required this.id,
    required this.dependentId,
    required this.vaccineName,
    this.dueDate,
    this.completedDate,
    required this.status,
  });

  factory VaccinationEntity.fromJson(Map<String, dynamic> json) {
    return VaccinationEntity(
      id: json['id'] as String,
      dependentId: json['dependent_id'] as String,
      vaccineName: json['vaccine_name'] as String,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date']) : null,
      status: json['status'] as String,
    );
  }
}
