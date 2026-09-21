import '../entities/vaccination_entity.dart';

abstract class IVaccinationRepository {
  Future<List<VaccinationEntity>> getVaccinations(String dependentId);
  
  Future<VaccinationEntity> createVaccination({
    required String dependentId,
    required String vaccineName,
    DateTime? dueDate,
    DateTime? completedDate,
    required String status,
  });

  Future<VaccinationEntity> markVaccinationCompleted(String vaccinationId, DateTime completedDate);
}
