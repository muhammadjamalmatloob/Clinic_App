import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_feedback_repository.dart';
import '../../data/repositories/feedback_repository.dart';
import 'api_client_provider.dart';

final feedbackRepositoryProvider = Provider<IFeedbackRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedbackRepository(apiClient);
});
