import 'package:freezed_annotation/freezed_annotation.dart';

part 'parsed_transaction.freezed.dart';
part 'parsed_transaction.g.dart';

@freezed
class ParsedTransaction with _$ParsedTransaction {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ParsedTransaction({
    String? type,
    int? amount,
    String? date,
    String? categoryName,
    String? categoryId,
    String? assetId,
    String? note,
    String? description,
    String? merchant,
    String? transactionDate,
    double? confidence,
    String? aiRawInput,
    String? pendingAttachmentPath,
  }) = _ParsedTransaction;

  factory ParsedTransaction.fromJson(Map<String, dynamic> json) => _$ParsedTransactionFromJson(json);
}
