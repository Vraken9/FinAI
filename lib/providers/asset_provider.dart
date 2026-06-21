import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/asset_repository.dart';
import '../data/models/asset.dart';

part 'asset_provider.g.dart';

@riverpod
class AssetNotifier extends _$AssetNotifier {
  late AssetRepository _repository;

  @override
  FutureOr<List<Asset>> build() async {
    _repository = AssetRepository();
    return _fetchAssets();
  }

  Future<List<Asset>> _fetchAssets() async {
    return await _repository.getAssets();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAssets());
  }

  Future<Asset> createAsset(Asset asset) async {
    final newAsset = await _repository.createAsset(asset);
    await refresh();
    return newAsset;
  }

  Future<void> updateAsset(String id, Map<String, dynamic> data) async {
    await _repository.updateAsset(id, data);
    await refresh();
  }

  Future<void> deleteAsset(String id) async {
    await _repository.deleteAsset(id);
    await refresh();
  }

  Future<void> setAssetAsDefault(String id) async {
    await _repository.setAssetAsDefault(id);
    await refresh();
  }

  Future<void> updateSortOrder(List<String> orderedIds) async {
    // Optimistic update
    if (state.valueOrNull != null) {
      final currentList = List<Asset>.from(state.value!);
      currentList.sort((a, b) {
        final aIndex = orderedIds.indexOf(a.id);
        final bIndex = orderedIds.indexOf(b.id);
        return aIndex.compareTo(bIndex);
      });
      state = AsyncValue.data(currentList);
    }
    
    await _repository.updateAssetSortOrder(orderedIds);
    await refresh();
  }
}
