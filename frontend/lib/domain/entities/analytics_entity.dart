class DailyAnalyticsEntity {
  final String date;
  final int totalPatients;
  final double averageWaitMinutes;
  final double completionRate;
  final int pendingCount;

  DailyAnalyticsEntity({
    required this.date,
    required this.totalPatients,
    required this.averageWaitMinutes,
    required this.completionRate,
    required this.pendingCount,
  });

  factory DailyAnalyticsEntity.fromJson(Map<String, dynamic> json) {
    return DailyAnalyticsEntity(
      date: json['date'] as String,
      totalPatients: json['total_patients'] as int,
      averageWaitMinutes: (json['average_wait_minutes'] as num).toDouble(),
      completionRate: (json['completion_rate'] as num).toDouble(),
      pendingCount: json['pending_count'] as int,
    );
  }
}
