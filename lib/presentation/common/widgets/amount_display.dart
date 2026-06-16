import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extension.dart';

class AmountDisplay extends StatelessWidget {
  final int amount;
  final String type;
  final TextStyle? style;

  const AmountDisplay({
    super.key,
    required this.amount,
    required this.type,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = type == 'expense';
    final isIncome = type == 'income';
    
    final color = isExpense 
        ? AppColors.expense 
        : (isIncome ? AppColors.income : Colors.black);
        
    final prefix = isExpense ? '-' : (isIncome ? '+' : '');
    
    return Text(
      '$prefix${amount.toCurrency()}',
      style: (style ?? AppTextStyles.body).copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
