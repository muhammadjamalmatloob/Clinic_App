import '../../core/network/api_client.dart';
import '../../domain/entities/vaccination_entity.dart';
import '../../domain/repositories/i_vaccination_repository.dart';

class VaccinationRepository implements IVaccinationRepository {
  final ApiClient apiClient;

  VaccinationRepository(this.apiClient);

  @override
  Future<List<VaccinationEntity>> getVaccinations(String dependentId) async {
    final response = await apiClient.dio.get('/dependents/$dependentId/vaccinations');
    final List data = response.data;
    return data.map((json) => VaccinationEntity.fromJson(json)).toList();
  }

  @override
  Future<VaccinationEntity> createVaccination({
    required String dependentId,
    required String vaccineName,
    DateTime? dueDate,
    DateTime? completedDate,
    required String status,
  }) async {
    final response = await apiClient.dio.post('/dependents/$dependentId/vaccinations', data: {
      'vaccine_name': vaccineName,
      if (dueDate != null) 'due_date': "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}",
      if (completedDate != null) 'completed_date': "${completedDate.year}-${completedDate.month.toString().padLeft(2, '0')}-${completedDate.day.toString().padLeft(2, '0')}",
      'status': status,
    });
    return VaccinationEntity.fromJson(response.data);
  }

  @override
  Future<VaccinationEntity> markVaccinationCompleted(String vaccinationId, DateTime completedDate) async {
    final dateStr = "${completedDate.year}-${completedDate.month.toString().padLeft(2, '0')}-${completedDate.day.toString().padLeft(2, '0')}";
    final response = await apiClient.dio.patch('/vaccinations/$vaccinationId', data: {
      'status': 'completed',
      'completed_date': dateStr,
    });
    return VaccinationEntity.fromJson(response.data);
  }
}
