import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../common/widgets/amount_display.dart';
import '../common/widgets/category_icon.dart';
import '../common/widgets/confirmation_dialog.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String id;

  const TransactionDetailScreen({super.key, required this.id});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Hapus Transaksi',
        message: 'Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.',
        confirmText: 'Hapus',
        isDestructive: true,
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(transactionNotifierProvider.notifier).deleteTransaction(id);
        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi dihapus')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur edit segera hadir')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: transactionsState.when(
        data: (transactions) {
          final tx = transactions.firstWhere((t) => t.id == id, orElse: () => throw Exception('Not found'));
          
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Column(
                  children: [
                    CategoryIcon(
                      iconName: tx.category?.icon ?? (tx.type == TransactionType.transfer ? 'swap_horiz' : 'tag'),
                      colorHex: tx.category?.color ?? '#888780',
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tx.category?.name ?? 'Transfer',
                      style: AppTextStyles.headline1.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    AmountDisplay(
                      amount: tx.amount,
                      type: tx.type.name,
                      style: AppTextStyles.amountLarge.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMMM yyyy, HH:mm').format(tx.transactionDate),
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              
              _buildDetailRow('Status', tx.status.name),
              _buildDetailRow('Dompet', tx.asset?.name ?? '-'),
              if (tx.type == TransactionType.transfer) ...[
                _buildDetailRow('Ke Dompet', tx.transferToAsset?.name ?? '-'),
                if (tx.transferFee != null && tx.transferFee! > 0)
                  _buildDetailRow('Biaya Transfer', 'Rp ${tx.transferFee}'),
              ],
              _buildDetailRow('Catatan', tx.note ?? '-'),
              if (tx.description != null && tx.description!.isNotEmpty)
                _buildDetailRow('Deskripsi', tx.description!),
              if (tx.merchant != null && tx.merchant!.isNotEmpty)
                _buildDetailRow('Merchant', tx.merchant!),
              _buildDetailRow('Dibuat via AI', tx.aiGenerated ? 'Ya' : 'Tidak'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
