import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class QuickPromptChips extends StatelessWidget {
  final Function(String) onPromptSelected;

  const QuickPromptChips({super.key, required this.onPromptSelected});

  final List<String> prompts = const [
    "Berapa pengeluaran makananku bulan ini?",
    "Apakah keuanganku sehat?",
    "Di mana aku paling boros?",
    "Berikan saran menabung untukku",
    "Bandingkan pengeluaranku dengan bulan lalu"
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: prompts.map((prompt) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(
                prompt,
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              side: const BorderSide(color: Colors.transparent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => onPromptSelected(prompt),
            ),
          );
        }).toList(),
      ),
    );
  }
}
