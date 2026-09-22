class AppointmentEntity {
  final String id;
  final String patientId;
  final String serviceId;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String? reason;

  AppointmentEntity({
    required this.id,
    required this.patientId,
    required this.serviceId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.reason,
  });

  factory AppointmentEntity.fromJson(Map<String, dynamic> json) {
    return AppointmentEntity(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      serviceId: json['service_id'] as String,
      appointmentDate: json['appointment_date'] as String,
      appointmentTime: json['appointment_time'] as String,
      status: json['status'] as String,
      reason: json['reason'] as String?,
    );
  }
}
