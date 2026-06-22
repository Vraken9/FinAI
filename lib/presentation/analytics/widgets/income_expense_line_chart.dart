import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../providers/analytics_provider.dart';
import '../../common/widgets/empty_state.dart';

class IncomeExpenseLineChart extends ConsumerWidget {
  const IncomeExpenseLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(incomeExpenseLineChartDataProvider);
    final incomeData = data['income'] ?? [];
    final expenseData = data['expense'] ?? [];

    if (incomeData.isEmpty && expenseData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: EmptyState(message: 'Tidak ada data tren', icon: Icons.show_chart),
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
              Text('Tren Pemasukan & Pengeluaran', style: AppTextStyles.headline1.copyWith(fontSize: 16)),
              // Bisa tambahkan tombol filter atau detail di sini nanti
            ],
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final avgIncome = incomeData.isEmpty ? 0.0 : incomeData.fold<double>(0, (sum, item) => sum + item['amount']) / incomeData.length;
              final avgExpense = expenseData.isEmpty ? 0.0 : expenseData.fold<double>(0, (sum, item) => sum + item['amount']) / expenseData.length;
              final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
              return Text(
                'Rata-rata harian: ${currencyFormat.format(avgIncome)} (Masuk) | ${currencyFormat.format(avgExpense)} (Keluar)',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
              );
            }
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppColors.surface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                        return LineTooltipItem(
                          'Tgl ${spot.x.toInt()}\n',
                          AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                          children: [
                            TextSpan(
                              text: currencyFormat.format(spot.y),
                              style: TextStyle(color: spot.bar.color, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                    dashArray: [4, 4], // Dashed line for cleaner look
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        // Only show specific days to avoid clutter
                        if (value.toInt() % 5 != 0 && value.toInt() != 1 && value.toInt() != 31) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            '${value.toInt()}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
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
                    curveSmoothness: 0.35,
                    color: AppColors.income,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.income.withValues(alpha: 0.3),
                          AppColors.income.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: expenseData.map((e) => FlSpot((e['day'] as int).toDouble(), (e['amount'] as int).toDouble())).toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.expense,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.expense.withValues(alpha: 0.3),
                          AppColors.expense.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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
