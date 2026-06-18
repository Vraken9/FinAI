// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetImpl _$$BudgetImplFromJson(Map<String, dynamic> json) => _$BudgetImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      amount: (json['amount'] as num).toInt(),
      periodMonth: (json['period_month'] as num).toInt(),
      periodYear: (json['period_year'] as num).toInt(),
      carryOver: json['carry_over'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      categoryName: json['category_name'] as String?,
      categoryIcon: json['category_icon'] as String?,
      categoryColor: json['category_color'] as String?,
      spentAmount: (json['spent_amount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$BudgetImplToJson(_$BudgetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'category_id': instance.categoryId,
      'amount': instance.amount,
      'period_month': instance.periodMonth,
      'period_year': instance.periodYear,
      'carry_over': instance.carryOver,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
