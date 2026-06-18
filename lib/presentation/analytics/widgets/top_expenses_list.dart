import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/extensions/datetime_extension.dart';
import '../../../../providers/analytics_provider.dart';

class TopExpensesList extends ConsumerWidget {
  const TopExpensesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MOCK DATA: Menggunakan TopExpensesData sesuai kesepakatan awal fase 2
    // CATATAN: Ini bisa diubah menggunakan data dari transactionNotifierProvider dengan sort limit
    final expenses = ref.watch(topExpensesDataProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pengeluaran Terbesar', style: AppTextStyles.headline1.copyWith(fontSize: 18)),
              Text(
                'Bulan Ini',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expenses.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = expenses[index];
              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.expense.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_cart, color: AppColors.expense, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item['category']} • ${(item['date'] as DateTime).toRelativeString()}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    (item['amount'] as int).toCurrency(),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.expense,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
