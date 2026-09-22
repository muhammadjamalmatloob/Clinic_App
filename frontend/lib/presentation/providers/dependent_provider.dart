import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_dependent_repository.dart';
import '../../data/repositories/dependent_repository.dart';
import '../../domain/entities/dependent_entity.dart';
import 'api_client_provider.dart';
import 'auth_provider.dart';

final dependentRepositoryProvider = Provider<IDependentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DependentRepository(apiClient);
});

final patientDependentsProvider = FutureProvider.autoDispose<List<DependentEntity>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];
  
  final repo = ref.watch(dependentRepositoryProvider);
  return repo.getDependents(user.id);
});
