import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/budget.dart';
import '../data/repositories/budget_repository.dart';

part 'budget_provider.g.dart';

@riverpod
class BudgetNotifier extends _$BudgetNotifier {
  late final BudgetRepository _repository;
  
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  int get currentMonth => _currentMonth;
  int get currentYear => _currentYear;

  @override
  FutureOr<List<Budget>> build() async {
    _repository = BudgetRepository();
    return _fetchBudgets();
  }

  Future<List<Budget>> _fetchBudgets() async {
    return await _repository.getBudgetProgress(_currentMonth, _currentYear);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBudgets());
  }
  
  void goToPreviousMonth() {
    if (_currentMonth == 1) {
      _currentMonth = 12;
      _currentYear--;
    } else {
      _currentMonth--;
    }
    refresh();
  }

  void goToNextMonth() {
    if (_currentMonth == 12) {
      _currentMonth = 1;
      _currentYear++;
    } else {
      _currentMonth++;
    }
    refresh();
  }

  Future<void> createBudget(Budget budget) async {
    await _repository.createBudget(budget);
    await refresh();
  }

  Future<void> updateBudget(String id, int newAmount) async {
    await _repository.updateBudget(id, newAmount);
    await refresh();
  }

  Future<void> deleteBudget(String id) async {
    await _repository.deleteBudget(id);
    await refresh();
  }
}
