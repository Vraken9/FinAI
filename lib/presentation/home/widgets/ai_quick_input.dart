import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AiQuickInput extends StatelessWidget {
  const AiQuickInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.auto_awesome, color: AppColors.primaryAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Ketik... "makan siang 25rb"',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (value) {
                  // TODO: Panggil AI parser sheet
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.mic_none, color: AppColors.primary),
              onPressed: () {
                // TODO: Buka ai_voice_input_sheet
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              onPressed: () {
                // TODO: Buka ai_scan_screen
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
