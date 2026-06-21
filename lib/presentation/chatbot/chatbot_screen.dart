import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/chat_provider.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/quick_prompt_chips.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100, // Extra padding
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) {
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('FinAI Advisor', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Text('Gagal memuat riwayat: $e'),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Halo! Aku FinAI Advisor.',
                          style: AppTextStyles.headline1.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tanyakan apa saja tentang keuanganmu.',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                // If the last message is from user and we are waiting, show a loading indicator.
                // In our optimistic update, the user message is added immediately.
                // We don't have an explicit 'isWaitingForAi' state, but we can infer it
                // if the last message is 'user'. Wait, no, because the user could be the last to talk in history.
                // Let's use the AsyncValue isLoading flag if we can, but StateNotifierProvider
                // doesn't easily expose it if we just push data. We can just check the last message.
                // Actually, our ChatNotifier wraps everything in try/catch and adds the response.

                final isLoading = ref.watch(isAiLoadingProvider);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      // This is the loading indicator
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _BouncingDot(delay: 0),
                                _BouncingDot(delay: 150),
                                _BouncingDot(delay: 300),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final msg = messages[index];
                    
                    if (msg.role == 'error') {
                      return ChatMessageBubble(
                        text: msg.content,
                        isUser: false,
                        isError: true,
                        onRetry: () {
                          ref.read(chatNotifierProvider.notifier).removeErrorMessage();
                        },
                      );
                    }
                    
                    return ChatMessageBubble(
                      text: msg.content,
                      isUser: msg.role == 'user',
                    );
                  },
                );
              },
            ),
          ),
          
          // Quick Prompts
          if (chatState.valueOrNull?.isEmpty ?? true)
            QuickPromptChips(
              onPromptSelected: _sendMessage,
            ),
            
          // Input Bar
          ChatInputBar(
            onSend: _sendMessage,
            isLoading: ref.watch(isAiLoadingProvider),
          ),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.5), shape: BoxShape.circle),
      ),
    );
  }
}
