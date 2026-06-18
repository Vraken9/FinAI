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
      userId: json['user_id'] as String,
      filePath: json['file_path'] as String,
      fileName: json['file_name'] as String,
      fileType: json['file_type'] as String,
      fileSizeBytes: (json['file_size_bytes'] as num).toInt(),
      isReceipt: json['is_receipt'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TransactionAttachmentImplToJson(
        _$TransactionAttachmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transaction_id': instance.transactionId,
      'user_id': instance.userId,
      'file_path': instance.filePath,
      'file_name': instance.fileName,
      'file_type': instance.fileType,
      'file_size_bytes': instance.fileSizeBytes,
      'is_receipt': instance.isReceipt,
      'created_at': instance.createdAt?.toIso8601String(),
    };
