import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/asset.dart';
import '../../../providers/asset_provider.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';

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

  void _showPicker(BuildContext context, WidgetRef ref, List<Asset> assets) {
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
              ListTile(
                leading: const Icon(Icons.add, color: AppColors.primary),
                title: const Text('Tambah Dompet Baru', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _showAddAssetDialog(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddAssetDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedType = 'cash';
    
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: true,
              child: AlertDialog(
              title: const Text('Tambah Dompet Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Dompet', 
                      border: const OutlineInputBorder(),
                      errorText: errorText,
                    ),
                    onChanged: (val) {
                      if (errorText != null) setState(() => errorText = null);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipe', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'bank', child: Text('Bank')),
                      DropdownMenuItem(value: 'e_wallet', child: Text('E-Wallet')),
                      DropdownMenuItem(value: 'investment', child: Text('Investasi')),
                      DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      setState(() => errorText = 'Nama dompet tidak boleh kosong');
                      return;
                    }
                    
                    final newAsset = Asset(
                      id: '',
                      userId: '', // Will be set by Supabase default or policy
                      name: nameController.text.trim(),
                      assetType: selectedType,
                      color: '#448AFF',
                      initialBalance: 0,
                      createdAt: DateTime.now(),
                    );
                    
                    try {
                      final created = await ref.read(assetNotifierProvider.notifier).createAsset(newAsset);
                      if (context.mounted) {
                        onSelected(created);
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menambah dompet: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsState = ref.watch(assetNotifierProvider);

    return ListTile(
      onTap: () {
        assetsState.whenData((assets) => _showPicker(context, ref, assets));
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
