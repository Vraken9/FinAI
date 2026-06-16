import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset.freezed.dart';
part 'asset.g.dart';

@freezed
class Asset with _$Asset {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Asset({
    required String id,
    required String userId,
    required String name,
    @Default('wallet') String icon,
    @Default('#185FA5') String color,
    @Default('other') String assetType,
    @Default(0) int initialBalance,
    @Default(false) bool isDefault,
    @Default(true) bool isActive,
    @Default(0) int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? currentBalance,
  }) = _Asset;

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
}
