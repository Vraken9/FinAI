import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';
import '../common/widgets/category_icon.dart';
import '../common/widgets/category_form_dialog.dart';
import '../common/widgets/confirmation_dialog.dart';
import '../common/widgets/loading_skeleton.dart';

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  ConsumerState<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends ConsumerState<ManageCategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCategoryForm({Category? category}) async {
    final defaultType = _tabController.index == 0 ? 'expense' : 'income';
    await showDialog<Category?>(
      context: context,
      useRootNavigator: true,
      builder: (context) => CategoryFormDialog(category: category, defaultType: defaultType),
    );
  }

  void _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Hapus Kategori',
        message: 'Yakin ingin menghapus kategori ${category.name}?',
        confirmText: 'Hapus',
        isDestructive: true,
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(categoryNotifierProvider.notifier).deleteCategory(category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori dihapus')));
        }
      } catch (e, stackTrace) {
        debugPrint('Delete category error: $e\n$stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
        }
      }
    }
  }

  void _toggleVisibility(Category category, bool isHidden) async {
    try {
      await ref.read(categoryNotifierProvider.notifier).updateCategory(category.id, {
        'is_hidden': isHidden,
      });
    } catch (e, stackTrace) {
      debugPrint('Toggle visibility error: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengubah visibilitas: $e')));
      }
    }
  }

  Widget _buildCategoryList(List<Category> allCategories, String type) {
    final categories = allCategories.where((c) => c.type == type || c.type == 'both').toList();
    
    if (categories.isEmpty) {
      return const Center(child: Text('Belum ada kategori'));
    }

    return ListView.builder(
      itemCount: categories.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: CategoryIcon(iconName: category.icon, colorHex: category.color, size: 40),
          title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(category.isSystem ? 'Sistem' : 'Kustom'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category.isSystem)
                Switch(
                  value: !category.isHidden,
                  onChanged: (val) => _toggleVisibility(category, !val),
                  activeThumbColor: AppColors.primary,
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () => _showCategoryForm(category: category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.expense),
                  onPressed: () => _deleteCategory(category),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
          ],
        ),
      ),
      body: categoriesState.when(
        loading: () => ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: LoadingSkeleton(height: 70),
          ),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (categories) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(categories, 'expense'),
              _buildCategoryList(categories, 'income'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCategoryForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
