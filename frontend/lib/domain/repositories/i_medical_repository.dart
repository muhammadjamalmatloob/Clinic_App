import '../entities/prescription_entity.dart';
import '../entities/medical_record_entity.dart';

abstract class IMedicalRepository {
  Future<PrescriptionEntity> createPrescription({
    required String patientId,
    required String doctorId,
    String? notes,
    required List<Map<String, dynamic>> items,
  });

  Future<List<PrescriptionEntity>> getPrescriptions({required String patientId});
  
  Future<List<MedicalRecordEntity>> getMedicalRecords({required String patientId});
}
