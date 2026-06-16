import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_attachment.freezed.dart';
part 'transaction_attachment.g.dart';

@freezed
class TransactionAttachment with _$TransactionAttachment {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TransactionAttachment({
    required String id,
    required String transactionId,
    required String fileUrl,
    required String fileType,
    DateTime? createdAt,
  }) = _TransactionAttachment;

  factory TransactionAttachment.fromJson(Map<String, dynamic> json) => _$TransactionAttachmentFromJson(json);
}
