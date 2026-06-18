import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
class Budget with _$Budget {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Budget({
    required String id,
    required String userId,
    required String categoryId,
    required int amount,
    required int periodMonth,
    required int periodYear,
    @Default(false) bool carryOver,
    DateTime? createdAt,
    DateTime? updatedAt,
    
    // View fields
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: true, includeToJson: false) String? categoryName,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: true, includeToJson: false) String? categoryIcon,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: true, includeToJson: false) String? categoryColor,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: true, includeToJson: false) int? spentAmount,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
}
