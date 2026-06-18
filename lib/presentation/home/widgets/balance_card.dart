import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../data/models/transaction.dart';
import '../../../../core/extensions/transaction_extension.dart';
import '../../../../providers/asset_provider.dart';
import '../../../../providers/transaction_provider.dart';

class BalanceCard extends ConsumerStatefulWidget {
  const BalanceCard({super.key});

  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> {
  bool _obscureBalance = false;

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetNotifierProvider);
    final transactionsAsync = ref.watch(transactionNotifierProvider);

    int totalBalance = 0;
    assetsAsync.whenData((assets) {
      for (var asset in assets) {
        totalBalance += asset.currentBalance ?? asset.initialBalance;
      }
    });

    int monthlyIncome = 0;
    int monthlyExpense = 0;
    transactionsAsync.whenData((transactions) {
      final now = DateTime.now();
      for (var t in transactions) {
        if (t.transactionDate.year == now.year && t.transactionDate.month == now.month) {
          if (t.type == TransactionType.income) {
            monthlyIncome += t.amount;
          } else {
            monthlyExpense += t.effectiveExpenseAmount;
          }
        }
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.2),
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
              const Text(
                'Total Saldo',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _obscureBalance = !_obscureBalance;
                  });
                },
                icon: Icon(
                  _obscureBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _obscureBalance ? 'Rp ••••••••' : totalBalance.toCurrency(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTransactionSummary(
                  title: 'Pemasukan',
                  amount: monthlyIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.income,
                  obscure: _obscureBalance,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTransactionSummary(
                  title: 'Pengeluaran',
                  amount: monthlyExpense,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.expense,
                  obscure: _obscureBalance,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary({
    required String title,
    required int amount,
    required IconData icon,
    required Color color,
    required bool obscure,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              obscure ? 'Rp ••••' : amount.toCurrency(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
