import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/budget.dart';

class BudgetRepository {
  final SupabaseClient _client;

  BudgetRepository() : _client = SupabaseService().client;

  Future<List<Budget>> getBudgetProgress(int month, int year) async {
    final response = await _client
        .from('budget_progress')
        .select()
        .eq('period_month', month)
        .eq('period_year', year);

    return response.map((json) => Budget.fromJson(json)).toList();
  }

  Future<Budget> createBudget(Budget budget) async {
    final Map<String, dynamic> data = budget.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    
    // View fields computed shouldn't be inserted
    data.remove('category_name');
    data.remove('category_icon');
    data.remove('category_color');
    data.remove('spent_amount');
    
    if (data['user_id'] == '') {
      data['user_id'] = _client.auth.currentUser?.id;
    }
    
    data.removeWhere((key, value) => value == null || (key == 'id' && value == ''));

    final response = await _client
        .from('budgets')
        .insert(data)
        .select()
        .single();

    return Budget.fromJson(response);
  }
}
