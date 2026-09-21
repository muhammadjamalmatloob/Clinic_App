import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_appointment_repository.dart';
import '../../data/repositories/appointment_repository.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import 'api_client_provider.dart';

final appointmentRepositoryProvider = Provider<IAppointmentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AppointmentRepository(apiClient);
});

final servicesProvider = FutureProvider<List<ServiceEntity>>((ref) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  return repo.getServices();
});

final appointmentsProvider = FutureProvider.autoDispose.family<List<AppointmentEntity>, String?>((ref, date) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  return repo.getAppointments(date: date);
});
