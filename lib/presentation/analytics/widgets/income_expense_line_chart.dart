import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../providers/analytics_provider.dart';

class IncomeExpenseLineChart extends ConsumerWidget {
  const IncomeExpenseLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MOCK DATA: Menggunakan IncomeExpenseLineChartData
    final data = ref.watch(incomeExpenseLineChartDataProvider);
    final incomeData = data['income'] ?? [];
    final expenseData = data['expense'] ?? [];

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
          Text('Tren Pemasukan & Pengeluaran', style: AppTextStyles.headline1.copyWith(fontSize: 18)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${value.toInt()}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: incomeData.map((e) => FlSpot((e['day'] as int).toDouble(), (e['amount'] as int).toDouble())).toList(),
                    isCurved: true,
                    color: AppColors.income,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.income.withValues(alpha: 0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: expenseData.map((e) => FlSpot((e['day'] as int).toDouble(), (e['amount'] as int).toDouble())).toList(),
                    isCurved: true,
                    color: AppColors.expense,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.expense.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppColors.income, 'Pemasukan'),
              const SizedBox(width: 24),
              _buildLegend(AppColors.expense, 'Pengeluaran'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 13)),
      ],
    );
  }
}
