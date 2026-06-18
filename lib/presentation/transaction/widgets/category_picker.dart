import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category.dart';
import '../../../providers/category_provider.dart';
import '../../common/widgets/category_icon.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';

class CategoryPicker extends ConsumerWidget {
  final Category? selectedCategory;
  final String transactionType;
  final ValueChanged<Category> onSelected;

  const CategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.transactionType,
    required this.onSelected,
  });

  void _showPicker(BuildContext context, WidgetRef ref, List<Category> categories) {
    final filtered = categories.where((c) => c.type == transactionType || c.type == 'both').toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Pilih Kategori', style: AppTextStyles.headline1.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filtered.length + 1,
                  itemBuilder: (context, index) {
                    if (index == filtered.length) {
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showAddCategoryDialog(context, ref);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                              child: const Icon(Icons.add, color: AppColors.primary),
                            ),
                            const SizedBox(height: 4),
                            Text('Tambah', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold), maxLines: 1),
                          ],
                        ),
                      );
                    }
                    final cat = filtered[index];
                    return InkWell(
                      onTap: () {
                        onSelected(cat);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CategoryIcon(iconName: cat.icon, colorHex: cat.color),
                          const SizedBox(height: 4),
                          Text(cat.name, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedIcon = 'category';
    String selectedColor = '#448AFF';
    
    final icons = ['restaurant', 'commute', 'shopping_cart', 'receipt_long', 'medical_services', 'build', 'school', 'local_movies', 'attach_money', 'category'];
    final colors = ['#FF5252', '#448AFF', '#69F0AE', '#FFD740', '#CE93D8', '#BDBDBD'];

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
              title: const Text('Tambah Kategori Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Kategori', 
                        border: const OutlineInputBorder(),
                        errorText: errorText,
                      ),
                      onChanged: (val) {
                        if (errorText != null) setState(() => errorText = null);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Warna:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: colors.map((c) => GestureDetector(
                        onTap: () => setState(() => selectedColor = c),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: Color(int.parse(c.substring(1, 7), radix: 16) + 0xFF000000),
                            shape: BoxShape.circle,
                            border: Border.all(color: selectedColor == c ? Colors.black : Colors.transparent, width: 2),
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Ikon:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: icons.map((ic) => GestureDetector(
                        onTap: () => setState(() => selectedIcon = ic),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selectedIcon == ic ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: selectedIcon == ic ? AppColors.primary : Colors.grey.shade300),
                          ),
                          child: Icon(_getIconData(ic), color: selectedIcon == ic ? AppColors.primary : Colors.grey),
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
                    if (nameController.text.trim().isEmpty) {
                      setState(() => errorText = 'Nama kategori tidak boleh kosong');
                      return;
                    }
                    
                    final newCat = Category(
                      id: '',
                      userId: '',
                      name: nameController.text.trim(),
                      icon: selectedIcon,
                      color: selectedColor,
                      type: transactionType,
                      createdAt: DateTime.now(),
                    );
                    
                    try {
                      final created = await ref.read(categoryNotifierProvider.notifier).addCategory(newCat);
                      if (context.mounted) {
                        onSelected(created);
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menambah kategori: $e')),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoryNotifierProvider);

    return ListTile(
      onTap: () {
        categoriesState.whenData((categories) => _showPicker(context, ref, categories));
      },
      leading: selectedCategory != null
          ? CategoryIcon(iconName: selectedCategory!.icon, colorHex: selectedCategory!.color, size: 32)
          : const Icon(Icons.category_outlined),
      title: Text(selectedCategory?.name ?? 'Pilih Kategori', style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
