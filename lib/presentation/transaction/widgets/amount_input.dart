import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Custom TextInputFormatter yang menambahkan separator titik setiap 3 digit.
/// Contoh: 20000 -> 20.000, 1500000 -> 1.500.000
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Hapus semua non-digit
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    // Format dengan separator titik
    final formatted = _addThousandsSeparator(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addThousandsSeparator(String digits) {
    final buffer = StringBuffer();
    final length = digits.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

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
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), // Allow digits and dots (dots added by formatter)
        ThousandsSeparatorInputFormatter(),
      ],
      textAlign: TextAlign.center,
      style: AppTextStyles.amountLarge.copyWith(color: color, fontSize: 36),
      decoration: InputDecoration(
        prefixText: 'Rp ',
        prefixStyle: AppTextStyles.amountLarge.copyWith(color: color, fontSize: 24),
        border: InputBorder.none,
        hintText: '0',
        hintStyle: AppTextStyles.amountLarge.copyWith(color: color.withValues(alpha: 0.5), fontSize: 36),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Masukkan nominal';
        }
        final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (digitsOnly.isEmpty || int.tryParse(digitsOnly) == 0) {
          return 'Masukkan nominal';
        }
        return null;
      },
    );
  }
}
