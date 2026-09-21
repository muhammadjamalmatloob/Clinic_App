import '../../core/network/api_client.dart';
import '../../domain/entities/medical_record_entity.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/repositories/i_medical_repository.dart';

class MedicalRepository implements IMedicalRepository {
  final ApiClient apiClient;

  MedicalRepository(this.apiClient);

  @override
  Future<PrescriptionEntity> createPrescription({
    required String patientId,
    required String doctorId,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await apiClient.dio.post('/prescriptions', data: {
      'patient_id': patientId,
      'doctor_id': doctorId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'items': items,
    });
    return PrescriptionEntity.fromJson(response.data);
  }

  @override
  Future<List<PrescriptionEntity>> getPrescriptions({required String patientId}) async {
    final response = await apiClient.dio.get('/prescriptions', queryParameters: {
      'patient_id': patientId,
    });
    final List data = response.data;
    return data.map((json) => PrescriptionEntity.fromJson(json)).toList();
  }

  @override
  Future<List<MedicalRecordEntity>> getMedicalRecords({required String patientId}) async {
    final response = await apiClient.dio.get('/medical-records', queryParameters: {
      'patient_id': patientId,
    });
    final List data = response.data;
    return data.map((json) => MedicalRecordEntity.fromJson(json)).toList();
  }
}
