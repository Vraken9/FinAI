import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/asset.dart';

class AssetRepository {
  final SupabaseClient _client;

  AssetRepository() : _client = SupabaseService().client;

  Future<List<Asset>> getAssets() async {
    final response = await _client
        .from('assets')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);
        
    return response.map((json) => Asset.fromJson(json)).toList();
  }

  Future<Asset> createAsset(Asset asset) async {
    final data = asset.toJson();
    data.remove('id');
    data.remove('current_balance');
    data.remove('created_at');
    data.remove('updated_at');
    data.remove('deleted_at');
    
    if (data['user_id'] == '') {
      data['user_id'] = _client.auth.currentUser?.id;
    }
    
    // Cleanup any null values or empty strings for UUID fields to ensure Supabase uses DB defaults
    data.removeWhere((key, value) => value == null || (key == 'id' && value == ''));

    final response = await _client
        .from('assets')
        .insert(data)
        .select()
        .single();
    return Asset.fromJson(response);
  }
}
