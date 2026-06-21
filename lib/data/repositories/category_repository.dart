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
        .isFilter('deleted_at', null)
        .or('user_id.eq.${user.id},user_id.is.null')
        .order('sort_order', ascending: true);

    return response.map((json) => Category.fromJson(json)).toList();
  }

  Future<Category> createCategory(Category category) async {
    final Map<String, dynamic> data = category.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    
    if (data['user_id'] == '') {
      data['user_id'] = _client.auth.currentUser?.id;
    }
    
    data.removeWhere((key, value) => value == null || (key == 'id' && value == ''));

    final response = await _client
        .from('categories')
        .insert(data)
        .select()
        .single();

    return Category.fromJson(response);
  }

  Future<Category> updateCategory(String id, Map<String, dynamic> data) async {
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    data.remove('user_id'); // Prevent modifying ownership
    
    final response = await _client
        .from('categories')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Category.fromJson(response);
  }

  Future<void> deleteCategory(String id) async {
    // Check for related transactions first
    final user = _client.auth.currentUser;
    if (user == null) return;
    
    final txResponse = await _client
        .from('transactions')
        .select('id')
        .eq('user_id', user.id)
        .isFilter('deleted_at', null)
        .eq('category_id', id)
        .limit(1);
        
    if ((txResponse as List).isNotEmpty) {
      throw Exception('Kategori tidak dapat dihapus karena masih digunakan pada transaksi aktif.');
    }

    // Soft delete
    await _client
        .from('categories')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
}
