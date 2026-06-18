import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/budget.dart';
import '../data/repositories/budget_repository.dart';

part 'budget_provider.g.dart';

@riverpod
class BudgetNotifier extends _$BudgetNotifier {
  late final BudgetRepository _repository;

  @override
  FutureOr<List<Budget>> build() async {
    _repository = BudgetRepository();
    return _fetchBudgets();
  }

  Future<List<Budget>> _fetchBudgets() async {
    final now = DateTime.now();
    return await _repository.getBudgetProgress(now.month, now.year);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBudgets());
  }

  Future<void> createBudget(Budget budget) async {
    final created = await _repository.createBudget(budget);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([...current, created]);
  }
}
