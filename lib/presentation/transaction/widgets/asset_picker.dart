import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/asset.dart';
import '../../../providers/asset_provider.dart';
import '../../../core/constants/app_text_styles.dart';

class AssetPicker extends ConsumerWidget {
  final Asset? selectedAsset;
  final ValueChanged<Asset> onSelected;
  final String label;

  const AssetPicker({
    super.key,
    required this.selectedAsset,
    required this.onSelected,
    this.label = 'Pilih Dompet',
  });

  void _showPicker(BuildContext context, List<Asset> assets) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.headline1.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              ...assets.map((asset) => ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(asset.name),
                onTap: () {
                  onSelected(asset);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsState = ref.watch(assetNotifierProvider);

    return ListTile(
      onTap: () {
        assetsState.whenData((assets) => _showPicker(context, assets));
      },
      leading: const Icon(Icons.account_balance_wallet_outlined),
      title: Text(selectedAsset?.name ?? label, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
