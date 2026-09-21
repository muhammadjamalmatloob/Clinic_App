import '../entities/dependent_entity.dart';

abstract class IDependentRepository {
  Future<List<DependentEntity>> getDependents(String guardianId);

  Future<DependentEntity> createDependent({
    required String guardianId,
    required String fullName,
    required String relationshipType,
    int? age,
  });

  Future<void> deleteDependent(String dependentId);
}
