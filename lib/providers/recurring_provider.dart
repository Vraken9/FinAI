import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/recurring_rule.dart';
import '../data/models/transaction.dart' as model_transaction;
import '../data/repositories/recurring_repository.dart';
import 'transaction_provider.dart';

part 'recurring_provider.g.dart';

@riverpod
class RecurringRulesNotifier extends _$RecurringRulesNotifier {
  late final RecurringRepository _repository;

  @override
  FutureOr<List<RecurringRule>> build() async {
    _repository = RecurringRepository();
    return _fetchRules();
  }

  Future<List<RecurringRule>> _fetchRules() async {
    return await _repository.getRecurringRules();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRules());
  }

  Future<void> createRule(RecurringRule rule) async {
    await _repository.createRecurringRule(rule);
    await refresh();
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _repository.toggleActive(id, isActive);
    await refresh();
  }

  Future<void> deleteRule(String id) async {
    await _repository.deleteRecurringRule(id);
    await refresh();
  }
}

@riverpod
class DraftTransactionsNotifier extends _$DraftTransactionsNotifier {
  late final RecurringRepository _repository;

  @override
  FutureOr<List<model_transaction.Transaction>> build() async {
    _repository = RecurringRepository();
    return _fetchDrafts();
  }

  Future<List<model_transaction.Transaction>> _fetchDrafts() async {
    return await _repository.getDraftTransactions();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDrafts());
  }

  Future<void> confirmDraft(String transactionId) async {
    await _repository.confirmDraft(transactionId);
    await refresh();
    // Invalidate transaction list so it updates Home & Analytics
    ref.invalidate(transactionNotifierProvider);
  }

  Future<void> skipDraft(String transactionId) async {
    await _repository.skipDraft(transactionId);
    await refresh();
    // Usually skipped drafts don't show up in normal transaction list, 
    // but invalidate just to be safe if they were caching drafts.
    ref.invalidate(transactionNotifierProvider);
  }
}

@riverpod
Future<List<RecurringRule>> upcomingRecurring(UpcomingRecurringRef ref, int days) async {
  final repository = RecurringRepository();
  return repository.getUpcomingRecurring(days);
}
