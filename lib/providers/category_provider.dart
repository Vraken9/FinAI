import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/category_repository.dart';
import '../data/models/category.dart';

part 'category_provider.g.dart';

@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  late CategoryRepository _repository;

  @override
  FutureOr<List<Category>> build() async {
    _repository = CategoryRepository();
    return _fetchCategories();
  }

  Future<List<Category>> _fetchCategories() async {
    return await _repository.getCategories();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCategories());
  }

  Future<Category> addCategory(Category category) async {
    final newCategory = await _repository.createCategory(category);
    await refresh();
    return newCategory;
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _repository.updateCategory(id, data);
    await refresh();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await refresh();
  }
}
