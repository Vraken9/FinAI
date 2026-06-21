import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/asset.dart';

class AssetRepository {
  final SupabaseClient _client;

  AssetRepository() : _client = SupabaseService().client;

  Future<List<Asset>> getAssets() async {
    // 1. Ambil data aset asli dari tabel 'assets' agar bisa memfilter is_active dan deleted_at
    final assetsData = await _client
        .from('assets')
        .select()
        .eq('is_active', true)
        .isFilter('deleted_at', null)
        .order('sort_order', ascending: true);
        
    // 2. Ambil saldo terkalkulasi dari view 'asset_balances'
    // (View ini memang tidak memiliki kolom is_active)
    final balancesData = await _client
        .from('asset_balances')
        .select('id, current_balance');
        
    // 3. Buat map saldo untuk pencarian cepat
    final balanceMap = {
      for (var b in balancesData) b['id'] as String: (b['current_balance'] as num).toInt()
    };
    
    // 4. Gabungkan data
    return assetsData.map((json) {
      final asset = Asset.fromJson(json);
      return asset.copyWith(
        currentBalance: balanceMap[asset.id] ?? asset.initialBalance,
      );
    }).toList();
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

  Future<Asset> updateAsset(String id, Map<String, dynamic> data) async {
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    
    final response = await _client
        .from('assets')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Asset.fromJson(response);
  }

  Future<void> deleteAsset(String id) async {
    // Soft delete
    await _client
        .from('assets')
        .update({
          'is_active': false,
          'deleted_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  Future<void> updateAssetSortOrder(List<String> orderedIds) async {
    for (int i = 0; i < orderedIds.length; i++) {
      await _client
          .from('assets')
          .update({'sort_order': i})
          .eq('id', orderedIds[i]);
    }
  }

  Future<void> setAssetAsDefault(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // Reset all assets to non-default
    await _client
        .from('assets')
        .update({'is_default': false})
        .eq('user_id', user.id);
        
    // Set the selected one as default
    await _client
        .from('assets')
        .update({'is_default': true})
        .eq('id', id);
  }
}
