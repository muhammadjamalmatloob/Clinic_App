import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_medical_repository.dart';
import '../../data/repositories/medical_repository.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/entities/medical_record_entity.dart';
import 'api_client_provider.dart';

final medicalRepositoryProvider = Provider<IMedicalRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MedicalRepository(apiClient);
});

final patientPrescriptionsProvider = FutureProvider.autoDispose.family<List<PrescriptionEntity>, String>((ref, patientId) async {
  final repo = ref.watch(medicalRepositoryProvider);
  return repo.getPrescriptions(patientId: patientId);
});

final patientMedicalRecordsProvider = FutureProvider.autoDispose.family<List<MedicalRecordEntity>, String>((ref, patientId) async {
  final repo = ref.watch(medicalRepositoryProvider);
  return repo.getMedicalRecords(patientId: patientId);
});
