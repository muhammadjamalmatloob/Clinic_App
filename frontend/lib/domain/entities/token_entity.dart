enum TokenStatus { waiting, serving, completed, cancelled, paused }

class TokenEntity {
  final String id;
  final int tokenNumber;
  final String patientId;
  final String patientName;
  final DateTime issuedAt;
  final TokenStatus status;
  final int estimatedWaitTimeMinutes; // Dynamic

  TokenEntity({
    required this.id,
    required this.tokenNumber,
    required this.patientId,
    required this.patientName,
    required this.issuedAt,
    this.status = TokenStatus.waiting,
    this.estimatedWaitTimeMinutes = 0,
  });

  TokenEntity copyWith({
    String? id,
    int? tokenNumber,
    String? patientId,
    String? patientName,
    DateTime? issuedAt,
    TokenStatus? status,
    int? estimatedWaitTimeMinutes,
  }) {
    return TokenEntity(
      id: id ?? this.id,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      issuedAt: issuedAt ?? this.issuedAt,
      status: status ?? this.status,
      estimatedWaitTimeMinutes: estimatedWaitTimeMinutes ?? this.estimatedWaitTimeMinutes,
    );
  }

  factory TokenEntity.fromJson(Map<String, dynamic> json) {
    TokenStatus parseStatus(String statusStr) {
      switch (statusStr.toLowerCase()) {
        case 'serving': return TokenStatus.serving;
        case 'completed': return TokenStatus.completed;
        case 'cancelled': return TokenStatus.cancelled;
        case 'paused': return TokenStatus.paused;
        case 'waiting':
        default:
          return TokenStatus.waiting;
      }
    }

    return TokenEntity(
      id: json['id'] as String,
      tokenNumber: json['token_number'] as int,
      patientId: json['patient_id']?.toString() ?? '',
      patientName: 'Patient', // Note: backend doesn't return name on token response
      issuedAt: DateTime.parse(json['issued_at']),
      status: parseStatus(json['status'] as String),
      estimatedWaitTimeMinutes: json['estimated_wait_minutes'] as int? ?? 0,
    );
  }
}
