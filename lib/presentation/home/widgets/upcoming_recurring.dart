import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../providers/recurring_provider.dart';

class UpcomingRecurringWidget extends ConsumerWidget {
  const UpcomingRecurringWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingState = ref.watch(upcomingRecurringProvider(7)); // Next 7 days

    return upcomingState.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent)),
      error: (err, stack) => const SizedBox.shrink(),
      data: (upcoming) {
        if (upcoming.isEmpty) return const SizedBox.shrink();

        return InkWell(
          onTap: () => context.push('/recurring'),
          child: Container(
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
              Icon(Icons.event_repeat, size: 16, color: AppColors.secondary),
              SizedBox(width: 8),
              Text(
                'Tagihan Mendatang',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...upcoming.map((rule) {
            final now = DateTime.now();
            final diff = rule.nextDueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
            String dueText;
            if (diff == 0) dueText = 'Hari ini';
            else if (diff == 1) dueText = 'Besok';
            else dueText = 'Dalam $diff hari';
            
            final isIncome = rule.transactionType == 'INCOME';
            final color = isIncome ? AppColors.income : AppColors.expense;
            final icon = isIncome ? Icons.download_rounded : Icons.upload_rounded;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 16, color: color),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rule.merchant ?? 'Tagihan',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            dueText,
                            style: TextStyle(
                              color: diff <= 3 ? AppColors.warning : AppColors.textSecondary, 
                              fontSize: 12,
                              fontWeight: diff <= 3 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    rule.amount.toCurrency(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ),
    );
      },
    );
  }
}
