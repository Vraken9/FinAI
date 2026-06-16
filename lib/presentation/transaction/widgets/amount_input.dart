import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String type;

  const AmountInput({
    super.key,
    required this.controller,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = type == 'expense' 
        ? AppColors.expense 
        : (type == 'income' ? AppColors.income : AppColors.primary);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      style: AppTextStyles.amountLarge.copyWith(color: color, fontSize: 36),
      decoration: InputDecoration(
        prefixText: 'Rp ',
        prefixStyle: AppTextStyles.amountLarge.copyWith(color: color, fontSize: 24),
        border: InputBorder.none,
        hintText: '0',
        hintStyle: AppTextStyles.amountLarge.copyWith(color: color.withOpacity(0.5), fontSize: 36),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || value == '0') {
          return 'Masukkan nominal';
        }
        return null;
      },
    );
  }
}
