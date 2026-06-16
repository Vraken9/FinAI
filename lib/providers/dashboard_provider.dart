import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardSummary extends _$DashboardSummary {
  @override
  Map<String, dynamic> build() {
    return {
      'totalBalance': 15450000,
      'monthlyIncome': 25000000,
      'monthlyExpense': 9550000,
      'savingRate': 61.8,
      'savingRateGrowth': 5.2, // compared to last month
      'healthScore': 85,
      'healthStatus': 'Sangat Baik',
      'healthDescription': 'Keuangan Anda dalam kondisi sangat baik. Tingkat tabungan Anda tinggi dan pengeluaran terkendali.',
      'criticalBudgets': [
        {'name': 'Makan', 'spent': 1800000, 'total': 2000000, 'percentage': 0.9},
        {'name': 'Transport', 'spent': 450000, 'total': 500000, 'percentage': 0.9},
      ],
      'upcomingRecurring': [
        {'name': 'Netflix', 'amount': 186000, 'daysLeft': 2},
      ],
    };
  }
}

@riverpod
class DailyExpenseChartData extends _$DailyExpenseChartData {
  @override
  List<Map<String, dynamic>> build() {
    // Mock 7 days data for the chart
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return {
        'date': date,
        'amount': 150000 + (index * 25000) - (index % 2 == 0 ? 50000 : 0),
      };
    });
  }
}
