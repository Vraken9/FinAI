import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/models/transaction.dart';

part 'transaction_provider.g.dart';

@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  late TransactionRepository _repository;

  @override
  FutureOr<List<Transaction>> build() async {
    _repository = TransactionRepository();
    return _fetchTransactions();
  }

  Future<List<Transaction>> _fetchTransactions() async {
    return await _repository.getTransactions();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTransactions());
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    final newTransaction = await _repository.addTransaction(transaction);
    await refresh();
    return newTransaction;
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    await refresh();
  }

  Future<void> updateTransaction(String id, Transaction transaction) async {
    final Map<String, dynamic> data = transaction.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    data.remove('category');
    data.remove('asset');
    data.remove('transfer_to_asset');
    data.remove('attachments');
    
    await _repository.updateTransaction(id, data);
    await refresh();
  }
}
