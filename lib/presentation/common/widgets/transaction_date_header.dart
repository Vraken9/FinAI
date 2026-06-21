import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';

class TransactionDateHeader extends StatelessWidget {
  final DateTime date;
  final int totalIncome;
  final int totalExpense;

  const TransactionDateHeader({
    super.key,
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
  });

  String _getShortDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Sen';
      case 2: return 'Sel';
      case 3: return 'Rab';
      case 4: return 'Kam';
      case 5: return 'Jum';
      case 6: return 'Sab';
      case 7: return 'Min';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String dayStr = DateFormat('dd').format(date);
    final String dayNameStr = _getShortDayName(date.weekday);
    final String monthYearStr = DateFormat('MM.yyyy').format(date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9), // Warna abu-abu sangat muda
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Date Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                dayStr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  dayNameStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                monthYearStr,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          // Right Side: Income & Expense Totals
          Row(
            children: [
              if (totalIncome > 0 || (totalIncome == 0 && totalExpense == 0))
                Text(
                  '+${totalIncome.toCurrency()}',
                  style: const TextStyle(
                    color: AppColors.income,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (totalIncome > 0 && totalExpense > 0)
                const SizedBox(width: 16),
              if (totalExpense > 0)
                Text(
                  '-${totalExpense.toCurrency()}',
                  style: const TextStyle(
                    color: AppColors.expense,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
