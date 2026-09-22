class FeedbackEntity {
  final String id;
  final String patientId;
  final String? appointmentId;
  final int rating;
  final String? comment;

  FeedbackEntity({
    required this.id,
    required this.patientId,
    this.appointmentId,
    required this.rating,
    this.comment,
  });

  factory FeedbackEntity.fromJson(Map<String, dynamic> json) {
    return FeedbackEntity(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      appointmentId: json['appointment_id'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
    );
  }
}
