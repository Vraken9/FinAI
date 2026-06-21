import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../data/models/ai_message.dart';
import '../data/repositories/chat_repository.dart';

final isAiLoadingProvider = StateProvider<bool>((ref) => false);

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, AsyncValue<List<AiMessage>>>((ref) {
  return ChatNotifier(ref.watch(chatRepositoryProvider), ref);
});

class ChatNotifier extends StateNotifier<AsyncValue<List<AiMessage>>> {
  final ChatRepository _chatRepository;
  final Ref _ref;

  ChatNotifier(this._chatRepository, this._ref) : super(const AsyncValue.loading()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _chatRepository.getConversationHistory();
      state = AsyncValue.data(history);
    } catch (e, stackTrace) {
      debugPrint('Error loading chat history: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> sendMessage(String text) async {
    final currentList = state.valueOrNull ?? [];
    
    // Optimistic update for User message
    final userMessage = AiMessage(
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    
    state = AsyncValue.data([...currentList, userMessage]);
    _ref.read(isAiLoadingProvider.notifier).state = true;

    try {
      // Create history map for API
      final historyMap = currentList.map((m) => {
        'role': m.role == 'user' ? 'user' : 'model',
        'text': m.content,
      }).toList();

      final aiResponse = await _chatRepository.sendMessage(text, historyMap);

      // Add AI response
      final assistantMessage = AiMessage(
        role: 'assistant',
        content: aiResponse,
        createdAt: DateTime.now(),
      );

      state = AsyncValue.data([...state.valueOrNull!, assistantMessage]);
    } catch (e) {
      debugPrint('Error sending AI message: $e');
      // Add error message as a special message
      final errorMessage = AiMessage(
        role: 'error',
        content: e.toString(),
        createdAt: DateTime.now(),
      );
      state = AsyncValue.data([...state.valueOrNull!, errorMessage]);
    } finally {
      _ref.read(isAiLoadingProvider.notifier).state = false;
    }
  }

  void removeErrorMessage() {
    final currentList = state.valueOrNull ?? [];
    final newList = currentList.where((m) => m.role != 'error').toList();
    state = AsyncValue.data(newList);
  }
}
