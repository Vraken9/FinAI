import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final SupabaseClient _client;

  TransactionRepository() : _client = SupabaseService().client;

  Future<List<Transaction>> getTransactions({int limit = 50, int offset = 0}) async {
    final response = await _client
        .from('transactions')
        .select('*, category:categories(*), asset:assets!transactions_asset_id_fkey(*), transferToAsset:assets!transactions_transfer_to_asset_id_fkey(*)')
        .isFilter('deleted_at', null)
        .order('transaction_date', ascending: false)
        .range(offset, offset + limit - 1);

    return response.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    final Map<String, dynamic> data = transaction.toJson();
    data.remove('category');
    data.remove('asset');
    data.remove('transfer_to_asset');
    data.remove('attachments');

    final response = await _client
        .from('transactions')
        .insert(data)
        .select()
        .single();

    return Transaction.fromJson(response);
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> updates) async {
    await _client.from('transactions').update(updates).eq('id', id);
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').update({'deleted_at': DateTime.now().toIso8601String()}).eq('id', id);
  }
}
