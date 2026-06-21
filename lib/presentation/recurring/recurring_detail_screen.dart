import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/recurring_provider.dart';
import '../common/widgets/confirmation_dialog.dart';

class RecurringDetailScreen extends ConsumerWidget {
  final String ruleId;

  const RecurringDetailScreen({super.key, required this.ruleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesState = ref.watch(recurringRulesNotifierProvider);
    final draftsState = ref.watch(draftTransactionsNotifierProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    final rule = rulesState.valueOrNull?.where((r) => r.id == ruleId).firstOrNull;

    if (rule == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tagihan')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final isIncome = rule.transactionType == 'INCOME';
    final color = isIncome ? AppColors.income : AppColors.expense;
    
    // Drafts for this rule
    final ruleDrafts = draftsState.valueOrNull?.where((t) => t.recurringRuleId == ruleId).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tagihan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: context.push('/recurring/edit/${rule.id}')
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => const ConfirmationDialog(
                  title: 'Hapus Tagihan',
                  message: 'Apakah Anda yakin ingin menghapus tagihan rutin ini? Draf yang belum dikonfirmasi akan tetap ada.',
                  confirmText: 'Hapus',
                  isDestructive: true,
                ),
              );
              if (confirm == true) {
                await ref.read(recurringRulesNotifierProvider.notifier).deleteRule(rule.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome ? Icons.download_rounded : Icons.upload_rounded,
                      color: color,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    rule.merchant ?? 'Tagihan Rutin',
                    style: AppTextStyles.headline1.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(rule.amount),
                    style: AppTextStyles.amountLarge.copyWith(color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Status Aktif', style: AppTextStyles.body),
                    value: rule.isActive,
                    activeColor: AppColors.primaryAccent,
                    onChanged: (val) {
                      ref.read(recurringRulesNotifierProvider.notifier).toggleActive(rule.id, val);
                    },
                  ),
                  const Divider(height: 1),
                  _buildDetailRow('Frekuensi', 'Setiap ${rule.frequency.name}'),
                  _buildDetailRow('Jatuh Tempo Berikutnya', dateFormat.format(rule.nextDueDate)),
                  _buildDetailRow('Tanggal Mulai', dateFormat.format(rule.startDate)),
                  if (rule.endDate != null)
                    _buildDetailRow('Tanggal Berakhir', dateFormat.format(rule.endDate!)),
                  if (rule.note != null && rule.note!.isNotEmpty)
                    _buildDetailRow('Catatan', rule.note!),
                ],
              ),
            ),
            if (ruleDrafts.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Draf Menunggu Konfirmasi', style: AppTextStyles.headline1.copyWith(fontSize: 18)),
              const SizedBox(height: 12),
              ...ruleDrafts.map((draft) => Card(
                elevation: 0,
                color: AppColors.warning.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.warning),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(draft.transactionDate),
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ref.read(draftTransactionsNotifierProvider.notifier).skipDraft(draft.id);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                              ),
                              child: const Text('Lewati'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ref.read(draftTransactionsNotifierProvider.notifier).confirmDraft(draft.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Konfirmasi'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
