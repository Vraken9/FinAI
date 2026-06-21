import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/recurring_rule.dart';
import '../models/transaction.dart' as model_transaction;

class RecurringRepository {
  final SupabaseClient _client;

  RecurringRepository() : _client = SupabaseService().client;

  Future<List<RecurringRule>> getRecurringRules() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('recurring_rules')
        .select()
        .eq('user_id', user.id)
        .isFilter('deleted_at', null)
        .order('next_due_date', ascending: true);

    return response.map((json) => RecurringRule.fromJson(json)).toList();
  }

  Future<List<RecurringRule>> getUpcomingRecurring(int days) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    final response = await _client
        .from('recurring_rules')
        .select()
        .eq('user_id', user.id)
        .isFilter('deleted_at', null)
        .eq('is_active', true)
        .gte('next_due_date', now.toUtc().toIso8601String())
        .lte('next_due_date', futureDate.toUtc().toIso8601String())
        .order('next_due_date', ascending: true);

    return response.map((json) => RecurringRule.fromJson(json)).toList();
  }

  Future<RecurringRule> createRecurringRule(RecurringRule rule) async {
    final Map<String, dynamic> data = rule.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    data.remove('deleted_at');
    data.remove('last_generated_at');
    
    if (data['user_id'] == '') {
      data['user_id'] = _client.auth.currentUser?.id;
    }
    
    data.removeWhere((key, value) => value == null || (key == 'id' && value == ''));

    final response = await _client
        .from('recurring_rules')
        .insert(data)
        .select()
        .single();

    return RecurringRule.fromJson(response);
  }

  Future<void> updateRecurringRule(String id, Map<String, dynamic> updates) async {
    final data = {...updates};
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    data.remove('deleted_at');
    
    data['updated_at'] = DateTime.now().toUtc().toIso8601String();

    await _client
        .from('recurring_rules')
        .update(data)
        .eq('id', id);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _client
        .from('recurring_rules')
        .update({
          'is_active': isActive, 
          'updated_at': DateTime.now().toUtc().toIso8601String()
        })
        .eq('id', id);
  }

  Future<void> deleteRecurringRule(String id) async {
    await _client
        .from('recurring_rules')
        .update({
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String()
        })
        .eq('id', id);
  }

  Future<List<model_transaction.Transaction>> getDraftTransactions() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('transactions')
        .select('*, category:categories(*), asset:assets!transactions_asset_id_fkey(*), transferToAsset:assets!transactions_transfer_to_asset_id_fkey(*), attachments:transaction_attachments(*)')
        .eq('user_id', user.id)
        .eq('status', 'draft')
        .not('recurring_rule_id', 'is', null)
        .isFilter('deleted_at', null)
        .order('transaction_date', ascending: true);

    return response.map((json) => model_transaction.Transaction.fromJson(json)).toList();
  }

  Future<void> confirmDraft(String transactionId) async {
    await _client
        .from('transactions')
        .update({
          'status': 'completed', 
          'updated_at': DateTime.now().toUtc().toIso8601String()
        })
        .eq('id', transactionId);
  }

  Future<void> skipDraft(String transactionId) async {
    // skipped is a status or deleted? PRD says status='skipped' or we can soft delete.
    // The prompt says: "skipDraft(String transactionId) — update status='skipped'"
    await _client
        .from('transactions')
        .update({
          'status': 'skipped', 
          'updated_at': DateTime.now().toUtc().toIso8601String()
        })
        .eq('id', transactionId);
  }
}
