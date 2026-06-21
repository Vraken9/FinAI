import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/recurring_provider.dart';
import '../common/widgets/empty_state.dart';
import 'package:intl/intl.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesState = ref.watch(recurringRulesNotifierProvider);
    final draftsState = ref.watch(draftTransactionsNotifierProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan Mendatang'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          draftsState.when(
            data: (drafts) {
              if (drafts.isEmpty) return const SizedBox.shrink();
              return InkWell(
                onTap: () {
                  // Scroll down to rules or maybe open a bottom sheet to show drafts? 
                  // For now, drafts are attached to rules, we can just highlight the banner.
                },
                child: Container(
                  width: double.infinity,
                  color: AppColors.warning.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${drafts.length} transaksi terjadwal menunggu konfirmasi',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: rulesState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent)),
              error: (err, stack) => Center(child: Text('Terjadi kesalahan: $err', style: AppTextStyles.body)),
              data: (rules) {
                if (rules.isEmpty) {
                  return EmptyState(
                    title: 'Belum ada tagihan rutin',
                    message: 'Buat tagihan/pendapatan rutin agar FinAI dapat mengingatkan Anda.',
                    icon: Icons.event_repeat,
                    actionLabel: '+ Tambah Tagihan',
                    onAction: () => context.push('/recurring/add'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(recurringRulesNotifierProvider.notifier).refresh();
                    await ref.read(draftTransactionsNotifierProvider.notifier).refresh();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: rules.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      final isIncome = rule.transactionType == 'INCOME';
                      final color = isIncome ? AppColors.income : AppColors.expense;
                      
                      final now = DateTime.now();
                      final diff = rule.nextDueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
                      String dueText;
                      if (diff == 0) {
                        dueText = 'Hari ini';
                      } else if (diff == 1) {
                        dueText = 'Besok';
                      } else if (diff < 0) {
                        dueText = 'Terlewat ${-diff} hari';
                      } else {
                        dueText = '$diff hari lagi';
                      }

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        color: Colors.white,
                        margin: EdgeInsets.zero,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/recurring/${rule.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isIncome ? Icons.download_rounded : Icons.upload_rounded,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rule.merchant ?? 'Tagihan Rutin',
                                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${currencyFormat.format(rule.amount)} setiap ${rule.frequency.name}',
                                        style: AppTextStyles.caption,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.event, size: 14, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            dueText,
                                            style: AppTextStyles.caption.copyWith(
                                              color: diff <= 3 && rule.isActive ? AppColors.warning : AppColors.textSecondary,
                                              fontWeight: diff <= 3 ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: rule.isActive,
                                  activeThumbColor: AppColors.primaryAccent,
                                  onChanged: (val) {
                                    ref.read(recurringRulesNotifierProvider.notifier).toggleActive(rule.id, val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/recurring/add'),
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tagihan'),
      ),
    );
  }
}
