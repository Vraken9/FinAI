import 'package:freezed_annotation/freezed_annotation.dart';
import 'category.dart';
import 'asset.dart';
import 'transaction_attachment.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionType { income, expense, transfer }
enum TransactionStatus { confirmed, draft, skipped }

@freezed
class Transaction with _$Transaction {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Transaction({
    required String id,
    required String userId,
    required TransactionType type,
    required int amount,
    required DateTime transactionDate,
    String? categoryId,
    required String assetId,
    String? transferToAssetId,
    int? transferFee,
    String? note,
    String? description,
    String? merchant,
    String? incomeSource,
    String? recurringRuleId,
    required bool aiGenerated,
    String? aiInputType,
    required TransactionStatus status,
    required DateTime createdAt,
    DateTime? deletedAt,
    
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: true, includeToJson: false) Category? category,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: true, includeToJson: false) Asset? asset,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: true, includeToJson: false) Asset? transferToAsset,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: true, includeToJson: false) List<TransactionAttachment>? attachments,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
