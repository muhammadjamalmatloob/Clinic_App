import '../entities/analytics_entity.dart';
import '../entities/announcement_entity.dart';

abstract class IClinicRepository {
  Future<DailyAnalyticsEntity> getDailyAnalytics({String? date});

  Future<AnnouncementEntity> createAnnouncement({
    required String createdById,
    required String message,
    String audience = 'all_patients',
  });

  Future<List<AnnouncementEntity>> getAnnouncements({String? audience});
}
