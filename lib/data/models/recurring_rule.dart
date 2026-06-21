// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_rule.freezed.dart';
part 'recurring_rule.g.dart';

enum RecurringFrequency {
  @JsonValue('daily') daily,
  @JsonValue('weekly') weekly,
  @JsonValue('biweekly') biweekly,
  @JsonValue('monthly') monthly,
  @JsonValue('yearly') yearly,
}

@freezed
class RecurringRule with _$RecurringRule {
  const factory RecurringRule({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'transaction_type') required String transactionType,
    @JsonKey(name: 'amount') required int amount,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'asset_id') required String assetId,
    @JsonKey(name: 'transfer_to_asset_id') String? transferToAssetId,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'merchant') String? merchant,
    @JsonKey(name: 'frequency') required RecurringFrequency frequency,
    @JsonKey(name: 'day_of_month') int? dayOfMonth,
    @JsonKey(name: 'day_of_week') int? dayOfWeek,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'next_due_date') required DateTime nextDueDate,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'last_generated_at') DateTime? lastGeneratedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _RecurringRule;

  factory RecurringRule.fromJson(Map<String, dynamic> json) => _$RecurringRuleFromJson(json);
}
