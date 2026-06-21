import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/budget_provider.dart';
import '../common/widgets/empty_state.dart';
import 'widgets/budget_category_card.dart';
import '../common/widgets/confirmation_dialog.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetNotifierProvider);
    final notifier = ref.read(budgetNotifierProvider.notifier);
    
    final currentMonth = notifier.currentMonth;
    final currentYear = notifier.currentYear;
    
    final monthName = DateFormat('MMMM yyyy', 'id_ID').format(DateTime(currentYear, currentMonth));
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggaran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/budget/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Navigation Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => notifier.goToPreviousMonth(),
                ),
                Text(
                  monthName,
                  style: AppTextStyles.headline1.copyWith(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => notifier.goToNextMonth(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: budgetState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent)),
              error: (err, stack) => Center(child: Text('Terjadi kesalahan: $err', style: AppTextStyles.body)),
              data: (budgets) {
                if (budgets.isEmpty) {
                  return EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Belum ada anggaran untuk bulan ini',
                    message: 'Buat anggaran pertama Anda untuk mulai melacak pengeluaran.',
                    actionLabel: '+ Buat Anggaran Pertama',
                    onAction: () => context.push('/budget/add'),
                  );
                }

                // Calculate Totals
                double totalBudget = 0;
                double totalSpent = 0;
                for (var b in budgets) {
                  totalBudget += b.amount;
                  totalSpent += (b.spentAmount ?? 0);
                }
                
                final totalPercentage = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;
                Color totalProgressColor = AppColors.primaryAccent;
                if (totalPercentage >= 0.9) {
                  totalProgressColor = AppColors.budgetOver;
                } else if (totalPercentage >= 0.6) {
                  totalProgressColor = AppColors.warning;
                }

                return RefreshIndicator(
                  onRefresh: () => notifier.refresh(),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Total Overview
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Anggaran', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text(currencyFormat.format(totalBudget), style: AppTextStyles.amountLarge.copyWith(fontSize: 24)),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: totalPercentage > 1.0 ? 1.0 : totalPercentage,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(totalProgressColor),
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Terpakai: ${currencyFormat.format(totalSpent)}',
                                  style: AppTextStyles.caption,
                                ),
                                Text(
                                  'Sisa: ${currencyFormat.format((totalBudget - totalSpent).clamp(0, double.infinity))}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Anggaran Kategori', style: AppTextStyles.headline1.copyWith(fontSize: 18)),
                      const SizedBox(height: 16),
                      
                      // List of Category Budgets
                      ...budgets.map((budget) => BudgetCategoryCard(
                        budget: budget,
                        onTap: () {
                          // Show bottom sheet to edit
                          _showEditBudgetSheet(context, ref, budget);
                        },
                        onLongPress: () {
                          // Show delete confirmation
                          _showDeleteConfirmation(context, ref, budget);
                        },
                      )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/budget/add'),
        backgroundColor: AppColors.primaryAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showEditBudgetSheet(BuildContext context, WidgetRef ref, budget) {
    final amountController = TextEditingController(text: budget.amount.toString());
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Anggaran', style: AppTextStyles.headline1.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: 'Nominal Anggaran',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newAmount = int.tryParse(amountController.text) ?? 0;
                  if (newAmount > 0) {
                    try {
                      await ref.read(budgetNotifierProvider.notifier).updateBudget(budget.id, newAmount);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      debugPrint('Error updating budget: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal memperbarui anggaran: $e')),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Simpan Perubahan',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, budget) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Hapus Anggaran',
        message: 'Apakah Anda yakin ingin menghapus anggaran untuk kategori ${budget.categoryName}?',
        confirmText: 'Hapus',
        cancelText: 'Batal',
        isDestructive: true,
      ),
    );

    if (result == true) {
      try {
        await ref.read(budgetNotifierProvider.notifier).deleteBudget(budget.id);
      } catch (e) {
        debugPrint('Error deleting budget: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus anggaran: $e')),
          );
        }
      }
    }
  }
}
