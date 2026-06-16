import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/transaction_provider.dart';
import '../common/widgets/transaction_list_item.dart';
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

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Transaksi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(transactionNotifierProvider.notifier).refresh(),
        child: transactionsState.when(
          data: (transactions) {
            final filtered = transactions.where((t) {
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

            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final tx = filtered[index];
                return TransactionListItem(
                  transaction: tx,
                  onTap: () => context.push('/transaction/${tx.id}'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transaction/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
