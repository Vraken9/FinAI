import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HealthScoreDetailScreen extends StatelessWidget {
  const HealthScoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded scores for demonstration based on PRD-02
    const savingRateScore = 30; // max 40
    const budgetComplianceScore = 20; // max 30
    const consistencyScore = 15; // max 20
    const emergencyFundScore = 5; // max 10
    const totalScore = savingRateScore + budgetComplianceScore + consistencyScore + emergencyFundScore;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Skor Kesehatan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Column(
                children: [
                  Text(
                    '$totalScore',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const Text('Skor Keseluruhan', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildScoreComponent(
            'Rasio Tabungan (Saving Rate)',
            savingRateScore,
            40,
            'Tabung minimal 20% dari pemasukan bulanan.',
          ),
          _buildScoreComponent(
            'Kepatuhan Anggaran',
            budgetComplianceScore,
            30,
            'Jaga pengeluaran agar tidak melebihi batas anggaran yang ditentukan.',
          ),
          _buildScoreComponent(
            'Konsistensi Pencatatan',
            consistencyScore,
            20,
            'Catat transaksi harian secara rutin tanpa bolong.',
          ),
          _buildScoreComponent(
            'Dana Darurat',
            emergencyFundScore,
            10,
            'Kumpulkan dana darurat minimal 3x pengeluaran bulanan.',
          ),
        ],
      ),
    );
  }

  Widget _buildScoreComponent(String title, int score, int maxScore, String tip) {
    final double progress = score / maxScore;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('$score / $maxScore', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryAccent)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: progress > 0.7 ? AppColors.income : (progress > 0.4 ? Colors.orange : AppColors.expense),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
