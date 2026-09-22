import 'dart:async';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/token_entity.dart';
import '../../domain/repositories/i_queue_repository.dart';

class QueueRepository implements IQueueRepository {
  final ApiClient apiClient;

  QueueRepository(this.apiClient);

  @override
  Stream<List<TokenEntity>> getQueueStream() async* {
    // Polling logic: fetch tokens every 3 seconds
    while (true) {
      try {
        final response = await apiClient.dio.get('/queues/today/tokens');
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          final tokens = data.map((json) => TokenEntity.fromJson(json)).toList();
          yield tokens;
        } else {
          yield [];
        }
      } catch (e) {
        print('Error fetching queue stream: $e');
        yield [];
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Stream<TokenEntity?> getCurrentServingTokenStream() async* {
    // Polling logic: fetch current token every 3 seconds
    while (true) {
      try {
        final response = await apiClient.dio.get('/queues/today/current');
        if (response.statusCode == 200 && response.data != null) {
          yield TokenEntity.fromJson(response.data);
        } else {
          yield null;
        }
      } catch (e) {
        print('Error fetching current serving token: $e');
        yield null;
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Future<TokenEntity> requestToken(String? patientId, String? dependentId, String patientName) async {
    try {
      final Map<String, dynamic> data = {};
      if (patientId != null) data['patient_id'] = patientId;
      if (dependentId != null) data['dependent_id'] = dependentId;
      
      final response = await apiClient.dio.post('/queues/today/tokens', data: data);
      if (response.statusCode == 201) {
        return TokenEntity.fromJson(response.data);
      }
      throw Exception('Failed to request token');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to request token: $e');
    }
  }

  @override
  Future<void> callNextPatient() async {
    try {
      await apiClient.dio.post('/queues/today/call-next');
    } catch (e) {
      print('Call next patient error: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeCurrentPatient() async {
    try {
      await apiClient.dio.post('/queues/today/complete-current');
    } catch (e) {
      print('Complete current patient error: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleQueuePauseStatus() async {
    try {
      // In a full implementation, we'd GET the queue status and toggle it.
      // For now we just hit the endpoint with active/paused based on logic.
      // Since toggle is asked, we should fetch current queue status first.
      final response = await apiClient.dio.get('/queues/today');
      if (response.statusCode == 200) {
        final currentStatus = response.data['status'];
        final newStatus = currentStatus == 'paused' ? 'active' : 'paused';
        await apiClient.dio.patch('/queues/today/status', data: {
          'status': newStatus,
        });
      }
    } catch (e) {
      print('Toggle queue status error: $e');
      rethrow;
    }
  }
}
