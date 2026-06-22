import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../providers/analytics_provider.dart';
import '../../common/widgets/empty_state.dart';

class ExpenseDonutChart extends ConsumerWidget {
  const ExpenseDonutChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(expenseDonutChartDataProvider);

    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: EmptyState(message: 'Tidak ada pengeluaran per kategori', icon: Icons.pie_chart),
      );
    }

    final double totalExpense = data.fold(0.0, (sum, item) => sum + (item['amount'] as int).toDouble());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengeluaran per Kategori', style: AppTextStyles.headline1.copyWith(fontSize: 18)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalExpense.toCurrency(),
                      style: AppTextStyles.headline1.copyWith(fontSize: 16),
                    ),
                  ],
                ),
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      enabled: true,
                    ),
                    sectionsSpace: 4,
                    centerSpaceRadius: 70,
                    sections: data.map((item) {
                      final colorStr = item['color'] as String;
                      final color = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
                      final amount = (item['amount'] as int).toDouble();
                      final percentage = (amount / totalExpense) * 100;
                      
                      return PieChartSectionData(
                        color: color,
                        value: amount,
                        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
                        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        showTitle: percentage > 5,
                        radius: 20,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: data.map((item) {
              final colorStr = item['color'] as String;
              final color = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
              final amount = item['amount'] as int;
              final percentage = (amount / totalExpense) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['category'] as String,
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          amount.toCurrency(),
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: color.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
