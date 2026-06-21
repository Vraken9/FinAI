import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/category.dart';
import '../../../providers/category_provider.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final Category? category;
  final String? defaultType;

  const CategoryFormDialog({super.key, this.category, this.defaultType});

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  late final TextEditingController _nameController;
  late String _selectedIcon;
  late String _selectedColor;
  late String _selectedType;
  String? _errorText;

  final _icons = ['restaurant', 'commute', 'shopping_cart', 'receipt_long', 'medical_services', 'build', 'school', 'local_movies', 'attach_money', 'category'];
  final _colors = ['#FF5252', '#448AFF', '#69F0AE', '#FFD740', '#CE93D8', '#BDBDBD'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.icon ?? 'category';
    _selectedColor = widget.category?.color ?? '#448AFF';
    _selectedType = widget.category?.type ?? widget.defaultType ?? 'expense';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'restaurant': return Icons.restaurant;
      case 'commute': return Icons.commute;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'receipt_long': return Icons.receipt_long;
      case 'medical_services': return Icons.medical_services;
      case 'build': return Icons.build;
      case 'school': return Icons.school;
      case 'local_movies': return Icons.local_movies;
      case 'attach_money': return Icons.attach_money;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori Baru'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Kategori', 
                border: const OutlineInputBorder(),
                errorText: _errorText,
              ),
              onChanged: (val) {
                if (_errorText != null) setState(() => _errorText = null);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Tipe', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 16),
            const Text('Pilih Warna:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colors.map((c) => GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Color(int.parse(c.substring(1, 7), radix: 16) + 0xFF000000),
                    shape: BoxShape.circle,
                    border: Border.all(color: _selectedColor == c ? Colors.black : Colors.transparent, width: 2),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Pilih Ikon:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _icons.map((ic) => GestureDetector(
                onTap: () => setState(() => _selectedIcon = ic),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIcon == ic ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _selectedIcon == ic ? AppColors.primary : Colors.grey.shade300),
                  ),
                  child: Icon(_getIconData(ic), color: _selectedIcon == ic ? AppColors.primary : Colors.grey),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () async {
            if (_nameController.text.trim().isEmpty) {
              setState(() => _errorText = 'Nama kategori tidak boleh kosong');
              return;
            }
            
            try {
              if (isEdit) {
                await ref.read(categoryNotifierProvider.notifier).updateCategory(widget.category!.id, {
                  'name': _nameController.text.trim(),
                  'icon': _selectedIcon,
                  'color': _selectedColor,
                  'type': _selectedType,
                });
                if (context.mounted) Navigator.pop(context, true);
              } else {
                final newCat = Category(
                  id: '',
                  userId: '',
                  name: _nameController.text.trim(),
                  icon: _selectedIcon,
                  color: _selectedColor,
                  type: _selectedType,
                  createdAt: DateTime.now(),
                );
                final created = await ref.read(categoryNotifierProvider.notifier).addCategory(newCat);
                if (context.mounted) Navigator.pop(context, created);
              }
            } catch (e) {
              debugPrint(e.toString());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menyimpan kategori: $e')),
                );
              }
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
