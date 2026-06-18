import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../providers/analytics_provider.dart';

class SummaryStatsRow extends ConsumerWidget {
  const SummaryStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MOCK DATA: Menggunakan AnalyticsSummaryData sesuai kesepakatan awal fase 2
    // CATATAN: Ini bisa diubah menggunakan data dari transactionNotifierProvider (seperti balance_card di Fase 1)
    final summaryData = ref.watch(analyticsSummaryDataProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Pemasukan',
                amount: summaryData['income'] ?? 0,
                color: AppColors.income,
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Pengeluaran',
                amount: summaryData['expense'] ?? 0,
                color: AppColors.expense,
                icon: Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Selisih',
                amount: summaryData['difference'] ?? 0,
                color: AppColors.primary,
                icon: Icons.swap_vert,
              ),
            ),
          ],
        ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int amount;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount.toCurrency(),
            style: AppTextStyles.headline1.copyWith(
              color: amount < 0 ? AppColors.expense : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
