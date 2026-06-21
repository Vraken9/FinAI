import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/currency_extension.dart';
import '../../core/extensions/transaction_extension.dart';
import '../../data/models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../common/widgets/transaction_list_item.dart';
import '../common/widgets/transaction_date_header.dart';
import '../common/widgets/empty_state.dart';
import '../common/widgets/error_state.dart';
import '../common/widgets/loading_skeleton.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  String _searchQuery = '';
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Transaksi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: AppTextStyles.headline1.copyWith(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari catatan, merchant, kategori...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(transactionNotifierProvider.notifier).refresh(),
        child: transactionsState.when(
          data: (transactions) {
            // Filter by month and search query
            final filtered = transactions.where((t) {
              if (t.transactionDate.year != _selectedMonth.year || t.transactionDate.month != _selectedMonth.month) {
                return false;
              }
              final searchStr = _searchQuery;
              if (searchStr.isEmpty) return true;
              return (t.note?.toLowerCase().contains(searchStr) ?? false) ||
                     (t.description?.toLowerCase().contains(searchStr) ?? false) ||
                     (t.merchant?.toLowerCase().contains(searchStr) ?? false) ||
                     (t.category?.name.toLowerCase().contains(searchStr) ?? false);
            }).toList();

            if (filtered.isEmpty) {
              return const EmptyState(message: 'Tidak ada transaksi ditemukan');
            }

            // Group by Date
            final Map<String, List<Transaction>> grouped = {};
            for (var t in filtered) {
              final dateStr = DateFormat('yyyy-MM-dd').format(t.transactionDate);
              if (!grouped.containsKey(dateStr)) {
                grouped[dateStr] = [];
              }
              grouped[dateStr]!.add(t);
            }

            final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 180),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateStr = sortedDates[index];
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

                final displayDate = DateFormat('dd MMMM yyyy').format(DateTime.parse(dateStr));

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
              },
            );
          },
          loading: () => const TransactionListSkeleton(),
          error: (err, _) => ErrorState(
            message: err.toString(),
            onRetry: () => ref.read(transactionNotifierProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}
