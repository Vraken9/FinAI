import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../providers/analytics_provider.dart';
import '../../common/widgets/empty_state.dart';

class MonthlyBarChart extends ConsumerWidget {
  const MonthlyBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(monthlyBarChartDataProvider);

    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: EmptyState(message: 'Tidak ada data bulanan', icon: Icons.bar_chart),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Perbandingan Bulanan', style: AppTextStyles.headline1.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final avgIncome = data.isEmpty ? 0.0 : data.fold<double>(0, (sum, item) => sum + (item['income'] as int)) / data.length;
              final avgExpense = data.isEmpty ? 0.0 : data.fold<double>(0, (sum, item) => sum + (item['expense'] as int)) / data.length;
              final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
              return Text(
                'Rata-rata bulanan: ${currencyFormat.format(avgIncome)} (Masuk) | ${currencyFormat.format(avgExpense)} (Keluar)',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
              );
            }
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data.fold<double>(0, (prev, item) {
                  final income = (item['income'] as int).toDouble();
                  final expense = (item['expense'] as int).toDouble();
                  final max = income > expense ? income : expense;
                  return max > prev ? max : prev;
                }) * 1.15, // 15% headroom
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                      final monthName = data[group.x.toInt()]['month'] as String;
                      final typeLabel = rodIndex == 0 ? 'Masuk' : 'Keluar';
                      return BarTooltipItem(
                        '$monthName ($typeLabel)\n',
                        AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                        children: [
                          TextSpan(
                            text: currencyFormat.format(rod.toY),
                            style: TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              data[index]['month'] as String,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (index) {
                  final item = data[index];
                  // Menghitung maxY lokal (bar ini) terhadap global max untuk background track
                  final maxVal = data.fold<double>(0, (prev, i) {
                    final inc = (i['income'] as int).toDouble();
                    final exp = (i['expense'] as int).toDouble();
                    final m = inc > exp ? inc : exp;
                    return m > prev ? m : prev;
                  }) * 1.15;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (item['income'] as int).toDouble(),
                        color: AppColors.income,
                        width: 12,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal == 0 ? 100 : maxVal,
                          color: Colors.grey.withValues(alpha: 0.08),
                        ),
                      ),
                      BarChartRodData(
                        toY: (item['expense'] as int).toDouble(),
                        color: AppColors.expense,
                        width: 12,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal == 0 ? 100 : maxVal,
                          color: Colors.grey.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  );
                }),
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
