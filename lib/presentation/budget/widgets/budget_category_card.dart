import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../data/models/budget.dart';
import '../../common/widgets/category_icon.dart';
import 'package:intl/intl.dart';

class BudgetCategoryCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const BudgetCategoryCard({
    super.key,
    required this.budget,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    // Safety check in case view hasn't updated or these are null
    final spentAmount = budget.spentAmount ?? 0;
    final percentage = budget.amount > 0 ? (spentAmount / budget.amount) : 0.0;
    
    Color progressColor;
    if (percentage < 0.6) {
      progressColor = AppColors.budgetSafe;
    } else if (percentage < 0.9) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.budgetOver;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryIcon(
                    iconName: budget.categoryIcon ?? 'help_outline',
                    colorHex: budget.categoryColor ?? '#9E9E9E',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      budget.categoryName ?? 'Kategori Tidak Diketahui',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.body.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: percentage > 1.0 ? 1.0 : percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormat.format(spentAmount),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    'dari ${currencyFormat.format(budget.amount)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
