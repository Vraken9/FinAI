import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/extensions/transaction_extension.dart';
import 'transaction_provider.dart';

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
    final transactionsState = ref.watch(transactionNotifierProvider);
    final transactions = transactionsState.valueOrNull ?? [];
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final Map<DateTime, int> dailyTotals = {};
    for (int i = 6; i >= 0; i--) {
      dailyTotals[today.subtract(Duration(days: i))] = 0;
    }
    
    for (final tx in transactions) {
      final expenseAmt = tx.effectiveExpenseAmount;
      if (expenseAmt > 0) {
        final txDate = DateTime(tx.transactionDate.year, tx.transactionDate.month, tx.transactionDate.day);
        if (dailyTotals.containsKey(txDate)) {
          dailyTotals[txDate] = dailyTotals[txDate]! + expenseAmt;
        }
      }
    }
    
    final result = dailyTotals.entries.map((e) => {
      'date': e.key,
      'amount': e.value,
    }).toList();
    
    // Sort by date ascending to ensure correct chart order
    result.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    return result;
  }
}
