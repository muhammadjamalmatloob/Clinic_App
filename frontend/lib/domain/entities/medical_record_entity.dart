class MedicalRecordEntity {
  final String id;
  final String patientId;
  final String? dependentId;
  final String? appointmentId;
  final String recordType;
  final String title;
  final String recordDate;
  final String? fileUrl;

  MedicalRecordEntity({
    required this.id,
    required this.patientId,
    this.dependentId,
    this.appointmentId,
    required this.recordType,
    required this.title,
    required this.recordDate,
    this.fileUrl,
  });

  factory MedicalRecordEntity.fromJson(Map<String, dynamic> json) {
    return MedicalRecordEntity(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      dependentId: json['dependent_id'] as String?,
      appointmentId: json['appointment_id'] as String?,
      recordType: json['record_type'] as String,
      title: json['title'] as String,
      recordDate: json['record_date'] as String,
      fileUrl: json['file_url'] as String?,
    );
  }
}
