import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatVoiceInputSheet extends ConsumerStatefulWidget {
  const ChatVoiceInputSheet({super.key});

  @override
  ConsumerState<ChatVoiceInputSheet> createState() => _ChatVoiceInputSheetState();
}

class _ChatVoiceInputSheetState extends ConsumerState<ChatVoiceInputSheet> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/chat_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _recordDuration = 0;
          _audioPath = null;
          _isProcessing = false;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() => _recordDuration++);
          if (_recordDuration >= 60) {
            _stopRecording();
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin mikrofon diperlukan. Silakan aktifkan di Settings.')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memulai perekaman suara')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    if (await _audioRecorder.isRecording()) {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });

      if (_recordDuration < 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Durasi rekaman terlalu singkat')),
          );
          Navigator.pop(context); // Batal
        }
        return;
      }

      if (path != null) {
        _submit(path);
      }
    }
  }

  Future<void> _submit(String path) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final repo = ref.read(chatRepositoryProvider);
      final text = await repo.transcribeVoice(File(path));
      if (mounted) {
        Navigator.pop(context, text);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            action: SnackBarAction(label: 'Coba Lagi', onPressed: () => _submit(path)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Rekam Pertanyaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (_isProcessing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Sedang menranskripsi...'),
              ],
            )
          else ...[
            Text(_formatDuration(_recordDuration), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isRecording ? _stopRecording : () {
                 if (_audioPath != null) {
                   _submit(_audioPath!);
                 } else {
                   _startRecording();
                 }
              },
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _isRecording ? Colors.red : Theme.of(context).primaryColor,
                child: Icon(_isRecording ? Icons.stop : (_audioPath != null ? Icons.send : Icons.mic), color: Colors.white, size: 32),
              ),
            ),
            if (!_isRecording && _audioPath != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _startRecording,
                child: const Text('Rekam Ulang'),
              )
            ] else if (_isRecording) ...[
              const SizedBox(height: 16),
              const Text('Ketuk tombol merah untuk berhenti', style: TextStyle(color: Colors.grey)),
            ]
          ],
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
