import '../../core/network/api_client.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/i_appointment_repository.dart';

class AppointmentRepository implements IAppointmentRepository {
  final ApiClient apiClient;

  AppointmentRepository(this.apiClient);

  @override
  Future<List<ServiceEntity>> getServices() async {
    final response = await apiClient.dio.get('/services');
    final List data = response.data;
    return data.map((json) => ServiceEntity.fromJson(json)).toList();
  }

  @override
  Future<AppointmentEntity> bookAppointment({
    required String patientId,
    required String serviceId,
    required String date,
    required String time,
    String? reason,
  }) async {
    final response = await apiClient.dio.post('/appointments', data: {
      'patient_id': patientId,
      'service_id': serviceId,
      'appointment_date': date,
      'appointment_time': time,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    return AppointmentEntity.fromJson(response.data);
  }

  @override
  Future<List<AppointmentEntity>> getAppointments({String? date, String? patientId}) async {
    final Map<String, dynamic> queryParams = {};
    if (date != null) queryParams['date'] = date;
    if (patientId != null) queryParams['patient_id'] = patientId;

    final response = await apiClient.dio.get('/appointments', queryParameters: queryParams);
    final List data = response.data;
    return data.map((json) => AppointmentEntity.fromJson(json)).toList();
  }

  @override
  Future<AppointmentEntity> updateAppointmentStatus(String appointmentId, String status) async {
    final response = await apiClient.dio.patch('/appointments/$appointmentId/status', data: {
      'status': status,
    });
    return AppointmentEntity.fromJson(response.data);
  }
}
