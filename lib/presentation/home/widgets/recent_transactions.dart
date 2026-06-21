import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/extensions/datetime_extension.dart';
import '../../../../core/extensions/transaction_extension.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/transaction.dart';
import '../../../../providers/transaction_provider.dart';
import '../../common/widgets/transaction_list_item.dart';
import '../../common/widgets/transaction_date_header.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionNotifierProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaksi Terakhir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to transaction list tab
                  // context.go('/transaction/list');
                },
                child: const Text('Lihat semua'),
              ),
            ],
          ),
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }
              // Ambil 10 transaksi terakhir agar groupingnya lebih terlihat
              final recent = transactions.take(10).toList();
              
              // Group by Date
              final Map<String, List<Transaction>> grouped = {};
              for (var t in recent) {
                final dateStr = DateFormat('yyyy-MM-dd').format(t.transactionDate);
                if (!grouped.containsKey(dateStr)) {
                  grouped[dateStr] = [];
                }
                grouped[dateStr]!.add(t);
              }

              final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

              return Column(
                children: sortedDates.map((dateStr) {
                  final dayTransactions = grouped[dateStr]!;
                  
                  int dayIncome = 0;
                  int dayExpense = 0;
                  for (var t in dayTransactions) {
                    if (t.type == TransactionType.income) {
                      dayIncome += t.amount;
                    } else {
                      dayExpense += t.effectiveExpenseAmount;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TransactionDateHeader(
                        date: DateTime.parse(dateStr),
                        totalIncome: dayIncome,
                        totalExpense: dayExpense,
                      ),
                      ...dayTransactions.map((tx) => TransactionListItem(
                            transaction: tx,
                            onTap: () => context.push('/transaction/${tx.id}'),
                          )),
                    ],
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}
