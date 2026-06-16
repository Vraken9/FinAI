import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/dashboard_provider.dart';

class BudgetProgressStrip extends ConsumerWidget {
  const BudgetProgressStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final criticalBudgets = summary['criticalBudgets'] as List<dynamic>? ?? [];

    if (criticalBudgets.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.budgetWarning),
              SizedBox(width: 8),
              Text(
                'Perhatian Anggaran',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...criticalBudgets.map((b) => _buildStrip(
            name: b['name'],
            percentage: b['percentage'],
          )),
        ],
      ),
    );
  }

  Widget _buildStrip({required String name, required double percentage}) {
    Color color = AppColors.budgetSafe;
    if (percentage >= 0.9) {
      color = AppColors.budgetOver;
    } else if (percentage >= 0.6) {
      color = AppColors.budgetWarning;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
