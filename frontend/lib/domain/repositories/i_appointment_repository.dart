import '../entities/appointment_entity.dart';
import '../entities/service_entity.dart';

abstract class IAppointmentRepository {
  Future<List<ServiceEntity>> getServices();
  Future<AppointmentEntity> bookAppointment({
    required String patientId,
    required String serviceId,
    required String date,
    required String time,
    String? reason,
  });
  Future<List<AppointmentEntity>> getAppointments({String? date, String? patientId});
  Future<AppointmentEntity> updateAppointmentStatus(String appointmentId, String status);
}
