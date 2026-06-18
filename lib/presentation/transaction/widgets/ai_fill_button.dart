import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/parsed_transaction.dart';
import '../../ai_input/ai_text_input_sheet.dart';
import '../../ai_input/ai_voice_input_sheet.dart';
import '../../ai_input/ai_scan_screen.dart';

class AiFillButton extends StatelessWidget {
  final Function(ParsedTransaction data, [File? image]) onAiParsed;

  const AiFillButton({super.key, required this.onAiParsed});

  Future<void> _showTextSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const AiTextInputSheet(),
    );
    if (result is ParsedTransaction) {
      onAiParsed(result);
    }
  }

  Future<void> _showVoiceSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const AiVoiceInputSheet(),
    );
    if (result is ParsedTransaction) {
      onAiParsed(result);
    }
  }

  Future<void> _showScanScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AiScanScreen()),
    );
    if (result is Map) {
      onAiParsed(result['data'] as ParsedTransaction, result['image'] as File?);
    }
  }

  void _showAiOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Isi Otomatis dengan AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.text_fields, color: Colors.purple),
                title: const Text('Ketik Teks'),
                subtitle: const Text('Contoh: Makan siang 25rb'),
                onTap: () {
                  Navigator.pop(context);
                  _showTextSheet(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mic, color: Colors.orange),
                title: const Text('Rekam Suara'),
                subtitle: const Text('Ucapkan transaksi Anda'),
                onTap: () {
                  Navigator.pop(context);
                  _showVoiceSheet(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Scan Struk'),
                subtitle: const Text('Foto struk belanja'),
                onTap: () {
                  Navigator.pop(context);
                  _showScanScreen(context);
                },
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'ai_fab', // prevent hero tag collision if there's another FAB
      onPressed: () => _showAiOptions(context),
      backgroundColor: Colors.purple, // AI color
      child: const Icon(Icons.auto_awesome, color: Colors.white),
    );
  }
}
