import '../entities/ai_entity.dart';

abstract class IAIRepository {
  Future<String> chat(List<ChatMessage> messages);
}
