import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'api_client_provider.dart';

final patientsProvider = FutureProvider.autoDispose<List<UserEntity>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/profiles', queryParameters: {
    'role': 'patient',
  });
  final List data = response.data;
  return data.map((json) => UserEntity.fromJson(json)).toList();
});
