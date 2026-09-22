import '../../core/network/api_client.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/i_clinic_repository.dart';

class ClinicRepository implements IClinicRepository {
  final ApiClient apiClient;

  ClinicRepository(this.apiClient);

  @override
  Future<DailyAnalyticsEntity> getDailyAnalytics({String? date}) async {
    final response = await apiClient.dio.get('/analytics/daily', queryParameters: {
      if (date != null) 'date': date,
    });
    return DailyAnalyticsEntity.fromJson(response.data);
  }

  @override
  Future<AnnouncementEntity> createAnnouncement({
    required String createdById,
    required String message,
    String audience = 'all_patients',
  }) async {
    final response = await apiClient.dio.post('/announcements', data: {
      'created_by_id': createdById,
      'message': message,
      'audience': audience,
    });
    return AnnouncementEntity.fromJson(response.data);
  }

  @override
  Future<List<AnnouncementEntity>> getAnnouncements({String? audience}) async {
    final response = await apiClient.dio.get('/announcements', queryParameters: {
      if (audience != null) 'audience': audience,
    });
    final List data = response.data;
    return data.map((json) => AnnouncementEntity.fromJson(json)).toList();
  }
}
