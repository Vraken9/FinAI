import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/currency_extension.dart';
import '../../data/models/asset.dart';
import '../../providers/asset_provider.dart';
import '../common/widgets/confirmation_dialog.dart';
import '../common/widgets/loading_skeleton.dart';

class ManageAssetsScreen extends ConsumerWidget {
  const ManageAssetsScreen({super.key});

  void _showAssetForm(BuildContext context, WidgetRef ref, {Asset? asset}) {
    final isEdit = asset != null;
    final nameController = TextEditingController(text: asset?.name);
    int balance = asset?.currentBalance ?? 0;
    String type = asset?.assetType ?? 'cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEdit ? 'Edit Dompet' : 'Tambah Dompet', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Dompet', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  if (!isEdit) ...[
                    TextFormField(
                      initialValue: balance.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Saldo Awal', border: OutlineInputBorder()),
                      onChanged: (val) => balance = int.tryParse(val) ?? 0,
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Tipe', border: OutlineInputBorder()),
                    items: ['cash', 'bank', 'e_wallet', 'investment', 'other'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.toUpperCase()));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => type = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;
                        try {
                          if (isEdit) {
                            await ref.read(assetNotifierProvider.notifier).updateAsset(asset.id, {
                              'name': nameController.text.trim(),
                              'asset_type': type,
                            });
                          } else {
                            await ref.read(assetNotifierProvider.notifier).createAsset(
                              Asset(
                                id: '',
                                userId: '',
                                name: nameController.text.trim(),
                                assetType: type,
                                initialBalance: balance,
                                isDefault: false,
                                isActive: true,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                            );
                          }
                          if (context.mounted) Navigator.pop(context);
                        } catch (e, stackTrace) {
                          debugPrint('Error saving asset: $e\n$stackTrace');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteAsset(BuildContext context, WidgetRef ref, Asset asset) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Hapus Dompet',
        message: 'Yakin ingin menghapus ${asset.name}?',
        confirmText: 'Hapus',
        isDestructive: true,
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(assetNotifierProvider.notifier).deleteAsset(asset.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dompet dihapus')));
        }
      } catch (e, stackTrace) {
        debugPrint('Delete asset error: $e\n$stackTrace');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsState = ref.watch(assetNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Dompet / Aset')),
      body: assetsState.when(
        loading: () => ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: LoadingSkeleton(height: 70),
          ),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (assets) {
          if (assets.isEmpty) {
            return const Center(child: Text('Belum ada dompet'));
          }

          return ReorderableListView.builder(
            itemCount: assets.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) newIndex -= 1;
              final list = List<Asset>.from(assets);
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);
              ref.read(assetNotifierProvider.notifier).updateSortOrder(list.map((e) => e.id).toList());
            },
            itemBuilder: (context, index) {
              final asset = assets[index];
              return ListTile(
                key: ValueKey(asset.id),
                leading: Radio<String>(
                  value: asset.id,
                  groupValue: assets.firstWhere((a) => a.isDefault, orElse: () => assets.first).id,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(assetNotifierProvider.notifier).setAssetAsDefault(val);
                    }
                  },
                ),
                title: Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text((asset.currentBalance ?? 0).toCurrency()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () => _showAssetForm(context, ref, asset: asset),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.expense),
                      onPressed: () => _deleteAsset(context, ref, asset),
                    ),
                    const Icon(Icons.drag_handle, color: Colors.grey),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssetForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
