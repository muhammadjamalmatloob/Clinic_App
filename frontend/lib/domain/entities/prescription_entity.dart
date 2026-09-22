class PrescriptionItemEntity {
  final String id;
  final String medicineName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  PrescriptionItemEntity({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory PrescriptionItemEntity.fromJson(Map<String, dynamic> json) {
    return PrescriptionItemEntity(
      id: json['id'] as String,
      medicineName: json['medicine_name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicine_name': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }
}

class PrescriptionEntity {
  final String id;
  final String patientId;
  final String? appointmentId;
  final String doctorId;
  final String? notes;
  final String issuedAt;
  final List<PrescriptionItemEntity> items;

  PrescriptionEntity({
    required this.id,
    required this.patientId,
    this.appointmentId,
    required this.doctorId,
    this.notes,
    required this.issuedAt,
    required this.items,
  });

  factory PrescriptionEntity.fromJson(Map<String, dynamic> json) {
    return PrescriptionEntity(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      appointmentId: json['appointment_id'] as String?,
      doctorId: json['doctor_id'] as String,
      notes: json['notes'] as String?,
      issuedAt: json['issued_at'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PrescriptionItemEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
