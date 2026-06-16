import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AiDailyInsight extends StatelessWidget {
  const AiDailyInsight({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                'Insight AI Hari Ini',
                style: TextStyle(
                  color: AppColors.income,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '"Pengeluaran transport Anda 20% lebih tinggi minggu ini dibandingkan minggu lalu. Coba cek ulang rute perjalanan Anda."',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
