import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_clinic_repository.dart';
import '../../data/repositories/clinic_repository.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/announcement_entity.dart';
import 'api_client_provider.dart';

final clinicRepositoryProvider = Provider<IClinicRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ClinicRepository(apiClient);
});

final dailyAnalyticsProvider = FutureProvider.autoDispose.family<DailyAnalyticsEntity, String?>((ref, date) async {
  final repo = ref.watch(clinicRepositoryProvider);
  return repo.getDailyAnalytics(date: date);
});

final announcementsProvider = FutureProvider.autoDispose.family<List<AnnouncementEntity>, String?>((ref, audience) async {
  final repo = ref.watch(clinicRepositoryProvider);
  return repo.getAnnouncements(audience: audience);
});
