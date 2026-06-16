import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category.dart';
import '../../../providers/category_provider.dart';
import '../../common/widgets/category_icon.dart';
import '../../../core/constants/app_text_styles.dart';

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

  void _showPicker(BuildContext context, List<Category> categories) {
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
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoryNotifierProvider);

    return ListTile(
      onTap: () {
        categoriesState.whenData((categories) => _showPicker(context, categories));
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
