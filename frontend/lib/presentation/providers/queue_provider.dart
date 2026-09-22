import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/i_queue_repository.dart';
import '../../data/repositories/queue_repository.dart';
import '../../domain/entities/token_entity.dart';
import 'api_client_provider.dart';

// Provides the single instance of our repository
final queueRepositoryProvider = Provider<IQueueRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QueueRepository(apiClient);
});

// Provides the stream of all tokens
final queueStreamProvider = StreamProvider<List<TokenEntity>>((ref) {
  final repo = ref.watch(queueRepositoryProvider);
  return repo.getQueueStream();
});

// Provides the current serving token
final currentServingTokenProvider = StreamProvider<TokenEntity?>((ref) {
  final repo = ref.watch(queueRepositoryProvider);
  return repo.getCurrentServingTokenStream();
});
