import '../../core/network/api_client.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';

class NotificationRepository implements INotificationRepository {
  final ApiClient apiClient;

  NotificationRepository(this.apiClient);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final response = await apiClient.dio.get('/notifications/');
    final List<dynamic> data = response.data;
    return data.map((json) => NotificationEntity.fromJson(json)).toList();
  }
}
