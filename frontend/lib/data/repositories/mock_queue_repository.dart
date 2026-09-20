import 'dart:async';
import 'package:uuid/uuid.dart';

import '../../domain/entities/token_entity.dart';
import '../../domain/repositories/i_queue_repository.dart';

class MockQueueRepository implements IQueueRepository {
  final _uuid = const Uuid();
  
  // Internal state
  final List<TokenEntity> _tokens = [];
  bool _isPaused = false;
  int _lastTokenNumber = 0;
  
  // Stream controllers
  final _queueController = StreamController<List<TokenEntity>>.broadcast();
  
  MockQueueRepository() {
    _emitState();
  }

  void _emitState() {
    _queueController.add(List.unmodifiable(_tokens));
  }

  @override
  Stream<List<TokenEntity>> getQueueStream() async* {
    yield List.unmodifiable(_tokens);
    yield* _queueController.stream;
  }

  @override
  Stream<TokenEntity?> getCurrentServingTokenStream() async* {
    TokenEntity? getServing(List<TokenEntity> tokens) {
      try {
        return tokens.firstWhere((t) => t.status == TokenStatus.serving);
      } catch (e) {
        return null;
      }
    }
    yield getServing(_tokens);
    yield* _queueController.stream.map(getServing);
  }

  @override
  Future<TokenEntity> requestToken(String patientId, String patientName) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
    
    _lastTokenNumber++;
    
    // Calculate wait time: 10 mins per waiting patient
    final waitingCount = _tokens.where((t) => t.status == TokenStatus.waiting || t.status == TokenStatus.serving).length;
    final estimatedTime = waitingCount * 10;

    final newToken = TokenEntity(
      id: _uuid.v4(),
      tokenNumber: _lastTokenNumber,
      patientId: patientId,
      patientName: patientName,
      issuedAt: DateTime.now(),
      status: TokenStatus.waiting,
      estimatedWaitTimeMinutes: estimatedTime,
    );
    
    _tokens.add(newToken);
    _emitState();
    return newToken;
  }

  @override
  Future<void> callNextPatient() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mark current serving as completed
    final currentServingIndex = _tokens.indexWhere((t) => t.status == TokenStatus.serving);
    if (currentServingIndex != -1) {
      _tokens[currentServingIndex] = _tokens[currentServingIndex].copyWith(status: TokenStatus.completed);
    }
    
    // Find next waiting
    final nextWaitingIndex = _tokens.indexWhere((t) => t.status == TokenStatus.waiting);
    if (nextWaitingIndex != -1) {
      _tokens[nextWaitingIndex] = _tokens[nextWaitingIndex].copyWith(status: TokenStatus.serving);
    }
    
    // Update wait times for all waiting
    for (int i = 0; i < _tokens.length; i++) {
      if (_tokens[i].status == TokenStatus.waiting) {
        final currentWait = _tokens[i].estimatedWaitTimeMinutes;
        _tokens[i] = _tokens[i].copyWith(
          estimatedWaitTimeMinutes: currentWait > 10 ? currentWait - 10 : 0,
        );
      }
    }
    
    _emitState();
  }

  @override
  Future<void> completeCurrentPatient() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final currentServingIndex = _tokens.indexWhere((t) => t.status == TokenStatus.serving);
    if (currentServingIndex != -1) {
      _tokens[currentServingIndex] = _tokens[currentServingIndex].copyWith(status: TokenStatus.completed);
      _emitState();
    }
  }

  @override
  Future<void> toggleQueuePauseStatus() async {
    _isPaused = !_isPaused;
    // For now just a boolean toggle. In a real app we'd pause wait time calculations.
  }
}
