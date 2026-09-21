import '../../core/network/api_client.dart';
import '../../domain/entities/ai_entity.dart';
import '../../domain/repositories/i_ai_repository.dart';

class AIRepository implements IAIRepository {
  final ApiClient apiClient;

  AIRepository(this.apiClient);

  @override
  Future<String> chat(List<ChatMessage> messages) async {
    final response = await apiClient.dio.post('/ai/chat', data: {
      'messages': messages.map((m) => m.toJson()).toList(),
    });
    return response.data['reply'] as String;
  }
}
