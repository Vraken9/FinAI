import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Category({
    required String id,
    String? userId,
    required String name,
    @Default('tag') String icon,
    @Default('#888780') String color,
    required String type,
    @Default(false) bool isSystem,
    @Default(false) bool isHidden,
    @Default(0) int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}
