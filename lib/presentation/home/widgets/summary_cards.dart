import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/transaction_extension.dart';
import '../../../../data/models/transaction.dart';
import '../../../../providers/transaction_provider.dart';

class SummaryCardsRow extends ConsumerWidget {
  const SummaryCardsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionNotifierProvider);

    double savingRate = 0.0;
    
    transactionsAsync.whenData((transactions) {
      final now = DateTime.now();
      int monthlyIncome = 0;
      int monthlyExpense = 0;
      
      for (var t in transactions) {
        if (t.transactionDate.year == now.year && t.transactionDate.month == now.month) {
          if (t.type == TransactionType.income) {
            monthlyIncome += t.amount;
          } else {
            monthlyExpense += t.effectiveExpenseAmount;
          }
        }
      }

      if (monthlyIncome > 0) {
        savingRate = ((monthlyIncome - monthlyExpense) / monthlyIncome) * 100;
        if (savingRate < 0) savingRate = 0;
      }
    });

    // TODO: implement growth logic later when data is more complex
    double growth = 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildCard(
              title: 'Saving Rate',
              value: '${savingRate.toStringAsFixed(1)}%',
              subtitle: 'Bulan ini',
              icon: Icons.savings_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildCard(
              title: 'Perbandingan',
              value: '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%',
              subtitle: 'vs Bulan lalu',
              icon: growth >= 0 ? Icons.trending_up : Icons.trending_down,
              valueColor: growth >= 0 ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
