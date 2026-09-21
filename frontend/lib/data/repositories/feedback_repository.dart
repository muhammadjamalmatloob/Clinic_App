import '../../core/network/api_client.dart';
import '../../domain/entities/feedback_entity.dart';
import '../../domain/repositories/i_feedback_repository.dart';

class FeedbackRepository implements IFeedbackRepository {
  final ApiClient apiClient;

  FeedbackRepository(this.apiClient);

  @override
  Future<FeedbackEntity> createFeedback({
    required String patientId,
    String? appointmentId,
    required int rating,
    String? comment,
  }) async {
    final response = await apiClient.dio.post('/feedback', data: {
      'patient_id': patientId,
      if (appointmentId != null) 'appointment_id': appointmentId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    return FeedbackEntity.fromJson(response.data);
  }
}
