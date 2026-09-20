import '../entities/token_entity.dart';

abstract class IQueueRepository {
  /// Stream of the currently active queue tokens. 
  /// In a real app, this would listen to Supabase realtime.
  Stream<List<TokenEntity>> getQueueStream();
  
  /// Patients call this to get a new token.
  Future<TokenEntity> requestToken(String patientId, String patientName);
  
  /// Staff calls this to progress the queue.
  Future<void> callNextPatient();
  
  /// Staff calls this to mark the current serving as completed.
  Future<void> completeCurrentPatient();
  
  /// Pause the queue for breaks.
  Future<void> toggleQueuePauseStatus();
  
  /// Get current serving token.
  Stream<TokenEntity?> getCurrentServingTokenStream();
}
