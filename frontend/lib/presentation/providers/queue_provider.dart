import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/i_queue_repository.dart';
import '../../data/repositories/mock_queue_repository.dart';
import '../../domain/entities/token_entity.dart';

// Provides the single instance of our repository
final queueRepositoryProvider = Provider<IQueueRepository>((ref) {
  return MockQueueRepository();
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
