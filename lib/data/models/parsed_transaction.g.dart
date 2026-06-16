// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParsedTransactionImpl _$$ParsedTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$ParsedTransactionImpl(
      type: json['type'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      date: json['date'] as String?,
      categoryName: json['category_name'] as String?,
      categoryId: json['category_id'] as String?,
      assetId: json['asset_id'] as String?,
      note: json['note'] as String?,
      description: json['description'] as String?,
      merchant: json['merchant'] as String?,
      transactionDate: json['transaction_date'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      aiRawInput: json['ai_raw_input'] as String?,
      pendingAttachmentPath: json['pending_attachment_path'] as String?,
    );

Map<String, dynamic> _$$ParsedTransactionImplToJson(
        _$ParsedTransactionImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'amount': instance.amount,
      'date': instance.date,
      'category_name': instance.categoryName,
      'category_id': instance.categoryId,
      'asset_id': instance.assetId,
      'note': instance.note,
      'description': instance.description,
      'merchant': instance.merchant,
      'transaction_date': instance.transactionDate,
      'confidence': instance.confidence,
      'ai_raw_input': instance.aiRawInput,
      'pending_attachment_path': instance.pendingAttachmentPath,
    };
