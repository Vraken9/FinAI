import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
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
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: data.map((item) {
                  final colorStr = item['color'] as String;
                  final color = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
                  return PieChartSectionData(
                    color: color,
                    value: (item['amount'] as int).toDouble(),
                    title: '', // Sembunyikan title di donut, pakai legend di bawah
                    radius: 20,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: data.map((item) {
              final colorStr = item['color'] as String;
              final color = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
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
                        style: AppTextStyles.body,
                      ),
                    ),
                    Text(
                      (item['amount'] as int).toCurrency(),
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
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
