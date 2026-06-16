import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ai_provider.dart';

class AiTextInputSheet extends ConsumerStatefulWidget {
  const AiTextInputSheet({super.key});

  @override
  ConsumerState<AiTextInputSheet> createState() => _AiTextInputSheetState();
}

class _AiTextInputSheetState extends ConsumerState<AiTextInputSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AiParseState>(aiParseProvider, (previous, next) {
      next.whenOrNull(
        success: (data) {
          Navigator.pop(context, data);
        },
        error: (message, isRetryable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              action: isRetryable ? SnackBarAction(label: 'Coba Lagi', onPressed: () => _submit()) : null,
            ),
          );
        },
      );
    });

    final aiState = ref.watch(aiParseProvider);
    final isLoading = aiState.maybeWhen(loading: () => true, orElse: () => false);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Ketik dengan bebas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            enabled: !isLoading,
            decoration: const InputDecoration(
              hintText: 'Misal: Makan siang ayam penyet 25rb pakai gopay',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Proses'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    ref.read(aiParseProvider.notifier).parseText(_controller.text.trim());
  }
}
