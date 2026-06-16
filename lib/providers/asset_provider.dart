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
}
