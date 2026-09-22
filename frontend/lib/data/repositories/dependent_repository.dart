import '../../core/network/api_client.dart';
import '../../domain/entities/dependent_entity.dart';
import '../../domain/repositories/i_dependent_repository.dart';

class DependentRepository implements IDependentRepository {
  final ApiClient apiClient;

  DependentRepository(this.apiClient);

  @override
  Future<List<DependentEntity>> getDependents(String guardianId) async {
    final response = await apiClient.dio.get('/dependents', queryParameters: {
      'guardian_id': guardianId,
    });
    final List data = response.data;
    return data.map((json) => DependentEntity.fromJson(json)).toList();
  }

  @override
  Future<DependentEntity> createDependent({
    required String guardianId,
    required String fullName,
    required String relationshipType,
    int? age,
  }) async {
    final response = await apiClient.dio.post('/dependents', data: {
      'guardian_id': guardianId,
      'full_name': fullName,
      'relationship_type': relationshipType,
      if (age != null) 'age': age,
    });
    return DependentEntity.fromJson(response.data);
  }

  @override
  Future<void> deleteDependent(String dependentId) async {
    await apiClient.dio.delete('/dependents/$dependentId');
  }
}
