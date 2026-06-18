import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/extensions/transaction_extension.dart';
import '../data/models/transaction.dart';
import 'transaction_provider.dart';

// === State Provider untuk Periode yang Dipilih ===
final selectedPeriodProvider = StateProvider<String>((ref) => '30H');

// Helper to filter transactions by period
List<Transaction> _filterTransactionsByPeriod(List<Transaction> transactions, String period) {
  final now = DateTime.now();
  DateTime startDate;
  
  switch (period) {
    case '7H':
      startDate = now.subtract(const Duration(days: 7));
      break;
    case '3B':
      startDate = DateTime(now.year, now.month - 3, now.day);
      break;
    case '6B':
      startDate = DateTime(now.year, now.month - 6, now.day);
      break;
    case 'Tahun':
      startDate = DateTime(now.year - 1, now.month, now.day);
      break;
    case '30H':
    default:
      startDate = now.subtract(const Duration(days: 30));
      break;
  }
  
  return transactions.where((t) => t.transactionDate.isAfter(startDate)).toList();
}

// === Real Data Providers ===

final analyticsSummaryDataProvider = Provider<Map<String, int>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final transactions = ref.watch(transactionNotifierProvider).valueOrNull ?? [];
  final filtered = _filterTransactionsByPeriod(transactions, period);
  
  int income = 0;
  int expense = 0;
  
  for (var t in filtered) {
    if (t.type == TransactionType.income) {
      income += t.amount;
    } else {
      expense += t.effectiveExpenseAmount;
    }
  }
  
  return {'income': income, 'expense': expense, 'difference': income - expense};
});

final expenseDonutChartDataProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final transactions = ref.watch(transactionNotifierProvider).valueOrNull ?? [];
  final filtered = _filterTransactionsByPeriod(transactions, period);
  
  final Map<String, Map<String, dynamic>> categoryTotals = {};
  
  for (var t in filtered) {
    final expenseAmt = t.effectiveExpenseAmount;
    if (expenseAmt > 0) {
      final catName = t.category?.name ?? (t.type == TransactionType.transfer ? 'Transfer Fee' : 'Lainnya');
      final color = t.category?.color ?? '#BDBDBD';
      
      if (!categoryTotals.containsKey(catName)) {
        categoryTotals[catName] = {'category': catName, 'amount': 0, 'color': color};
      }
      categoryTotals[catName]!['amount'] += expenseAmt;
    }
  }
  
  final result = categoryTotals.values.toList();
  result.sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));
  return result;
});

final incomeExpenseLineChartDataProvider = Provider<Map<String, List<Map<String, dynamic>>>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final transactions = ref.watch(transactionNotifierProvider).valueOrNull ?? [];
  final filtered = _filterTransactionsByPeriod(transactions, period);
  
  // A simplified grouping logic. Ideally groups by Day, Week or Month depending on period length.
  // For simplicity, we group by Day of year.
  final Map<int, int> incomeMap = {};
  final Map<int, int> expenseMap = {};
  
  for (var t in filtered) {
    final dayKey = t.transactionDate.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    if (t.type == TransactionType.income) {
      incomeMap[dayKey] = (incomeMap[dayKey] ?? 0) + t.amount;
    } else {
      final exp = t.effectiveExpenseAmount;
      if (exp > 0) expenseMap[dayKey] = (expenseMap[dayKey] ?? 0) + exp;
    }
  }
  
  final incomeList = incomeMap.entries.map((e) => {'day': e.key, 'amount': e.value}).toList();
  final expenseList = expenseMap.entries.map((e) => {'day': e.key, 'amount': e.value}).toList();
  
  incomeList.sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
  expenseList.sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
  
  // Normalize 'day' to 1..N for UI
  int i = 1;
  for (var item in incomeList) { item['day'] = i++; }
  i = 1;
  for (var item in expenseList) { item['day'] = i++; }
  
  return {'income': incomeList, 'expense': expenseList};
});

final monthlyBarChartDataProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final transactions = ref.watch(transactionNotifierProvider).valueOrNull ?? [];
  final filtered = _filterTransactionsByPeriod(transactions, period);
  
  final Map<String, Map<String, dynamic>> monthlyTotals = {};
  
  for (var t in filtered) {
    final monthKey = '${t.transactionDate.year}-${t.transactionDate.month.toString().padLeft(2, '0')}';
    
    if (!monthlyTotals.containsKey(monthKey)) {
      monthlyTotals[monthKey] = {
        'month': monthKey, // TODO: map to actual names like 'Jan', 'Feb'
        'income': 0,
        'expense': 0,
      };
    }
    
    if (t.type == TransactionType.income) {
      monthlyTotals[monthKey]!['income'] += t.amount;
    } else {
      monthlyTotals[monthKey]!['expense'] += t.effectiveExpenseAmount;
    }
  }
  
  final result = monthlyTotals.values.toList();
  result.sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
  return result;
});

final topExpensesDataProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final transactions = ref.watch(transactionNotifierProvider).valueOrNull ?? [];
  final filtered = _filterTransactionsByPeriod(transactions, period);
  
  final List<Map<String, dynamic>> expenses = [];
  
  for (var t in filtered) {
    final expenseAmt = t.effectiveExpenseAmount;
    if (expenseAmt > 0) {
      expenses.add({
        'name': t.merchant ?? t.note ?? (t.type == TransactionType.transfer ? 'Biaya Transfer' : 'Pengeluaran'),
        'category': t.category?.name ?? 'Lainnya',
        'amount': expenseAmt,
        'date': t.transactionDate,
      });
    }
  }
  
  expenses.sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));
  return expenses.take(5).toList();
});
