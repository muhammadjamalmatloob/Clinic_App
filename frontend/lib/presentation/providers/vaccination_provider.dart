import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_vaccination_repository.dart';
import '../../data/repositories/vaccination_repository.dart';
import '../../domain/entities/vaccination_entity.dart';
import 'api_client_provider.dart';

final vaccinationRepositoryProvider = Provider<IVaccinationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VaccinationRepository(apiClient);
});

final dependentVaccinationsProvider = FutureProvider.family.autoDispose<List<VaccinationEntity>, String>((ref, dependentId) async {
  final repo = ref.watch(vaccinationRepositoryProvider);
  return repo.getVaccinations(dependentId);
});
