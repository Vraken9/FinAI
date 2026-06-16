// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionAttachmentImpl _$$TransactionAttachmentImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionAttachmentImpl(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TransactionAttachmentImplToJson(
        _$TransactionAttachmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transaction_id': instance.transactionId,
      'file_url': instance.fileUrl,
      'file_type': instance.fileType,
      'created_at': instance.createdAt?.toIso8601String(),
    };
