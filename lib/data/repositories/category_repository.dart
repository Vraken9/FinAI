import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/category.dart';

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository() : _client = SupabaseService().client;

  Future<List<Category>> getCategories() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('categories')
        .select()
        .eq('is_hidden', false)
        .or('user_id.eq.${user.id},user_id.is.null')
        .order('sort_order', ascending: true);

    return response.map((json) => Category.fromJson(json)).toList();
  }
}
