import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 76)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showTextSheet(context),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primaryAccent),
                  const SizedBox(width: 8),
                  Text('Isi otomatis dengan AI', style: AppTextStyles.body.copyWith(color: AppColors.primaryAccent, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: AppColors.primaryAccent),
            onPressed: () => _showVoiceSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AppColors.primaryAccent),
            onPressed: () => _showScanScreen(context),
          ),
        ],
      ),
    );
  }
}
