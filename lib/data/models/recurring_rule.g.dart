// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurringRuleImpl _$$RecurringRuleImplFromJson(Map<String, dynamic> json) =>
    _$RecurringRuleImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      transactionType: json['transaction_type'] as String,
      amount: (json['amount'] as num).toInt(),
      categoryId: json['category_id'] as String,
      assetId: json['asset_id'] as String,
      transferToAssetId: json['transfer_to_asset_id'] as String?,
      note: json['note'] as String?,
      description: json['description'] as String?,
      merchant: json['merchant'] as String?,
      frequency: $enumDecode(_$RecurringFrequencyEnumMap, json['frequency']),
      dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
      dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      nextDueDate: DateTime.parse(json['next_due_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      lastGeneratedAt: json['last_generated_at'] == null
          ? null
          : DateTime.parse(json['last_generated_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$$RecurringRuleImplToJson(_$RecurringRuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'transaction_type': instance.transactionType,
      'amount': instance.amount,
      'category_id': instance.categoryId,
      'asset_id': instance.assetId,
      'transfer_to_asset_id': instance.transferToAssetId,
      'note': instance.note,
      'description': instance.description,
      'merchant': instance.merchant,
      'frequency': _$RecurringFrequencyEnumMap[instance.frequency]!,
      'day_of_month': instance.dayOfMonth,
      'day_of_week': instance.dayOfWeek,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'next_due_date': instance.nextDueDate.toIso8601String(),
      'is_active': instance.isActive,
      'last_generated_at': instance.lastGeneratedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

const _$RecurringFrequencyEnumMap = {
  RecurringFrequency.daily: 'daily',
  RecurringFrequency.weekly: 'weekly',
  RecurringFrequency.biweekly: 'biweekly',
  RecurringFrequency.monthly: 'monthly',
  RecurringFrequency.yearly: 'yearly',
};
