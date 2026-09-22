import '../entities/feedback_entity.dart';

abstract class IFeedbackRepository {
  Future<FeedbackEntity> createFeedback({
    required String patientId,
    String? appointmentId,
    required int rating,
    String? comment,
  });
}
