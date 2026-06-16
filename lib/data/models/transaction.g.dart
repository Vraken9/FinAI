// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toInt(),
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      categoryId: json['category_id'] as String?,
      assetId: json['asset_id'] as String,
      transferToAssetId: json['transfer_to_asset_id'] as String?,
      transferFee: (json['transfer_fee'] as num?)?.toInt(),
      note: json['note'] as String?,
      description: json['description'] as String?,
      merchant: json['merchant'] as String?,
      incomeSource: json['income_source'] as String?,
      recurringRuleId: json['recurring_rule_id'] as String?,
      aiGenerated: json['ai_generated'] as bool,
      aiInputType: json['ai_input_type'] as String?,
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      asset: json['asset'] == null
          ? null
          : Asset.fromJson(json['asset'] as Map<String, dynamic>),
      transferToAsset: json['transfer_to_asset'] == null
          ? null
          : Asset.fromJson(json['transfer_to_asset'] as Map<String, dynamic>),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map(
              (e) => TransactionAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'transaction_date': instance.transactionDate.toIso8601String(),
      'category_id': instance.categoryId,
      'asset_id': instance.assetId,
      'transfer_to_asset_id': instance.transferToAssetId,
      'transfer_fee': instance.transferFee,
      'note': instance.note,
      'description': instance.description,
      'merchant': instance.merchant,
      'income_source': instance.incomeSource,
      'recurring_rule_id': instance.recurringRuleId,
      'ai_generated': instance.aiGenerated,
      'ai_input_type': instance.aiInputType,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
  TransactionType.transfer: 'transfer',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.confirmed: 'confirmed',
  TransactionStatus.draft: 'draft',
  TransactionStatus.skipped: 'skipped',
};
