import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_ai_repository.dart';
import '../../data/repositories/ai_repository.dart';
import 'api_client_provider.dart';

final aiRepositoryProvider = Provider<IAIRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AIRepository(apiClient);
});
