// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  DateTime get transactionDate => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String get assetId => throw _privateConstructorUsedError;
  String? get transferToAssetId => throw _privateConstructorUsedError;
  int? get transferFee => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get merchant => throw _privateConstructorUsedError;
  String? get incomeSource => throw _privateConstructorUsedError;
  String? get recurringRuleId => throw _privateConstructorUsedError;
  bool get aiGenerated => throw _privateConstructorUsedError;
  String? get aiInputType => throw _privateConstructorUsedError;
  TransactionStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeFromJson: true, includeToJson: false)
  Category? get category =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeFromJson: true, includeToJson: false)
  Asset? get asset =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeFromJson: true, includeToJson: false)
  Asset? get transferToAsset =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(includeFromJson: true, includeToJson: false)
  List<TransactionAttachment>? get attachments =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String id,
      String userId,
      TransactionType type,
      int amount,
      DateTime transactionDate,
      String? categoryId,
      String assetId,
      String? transferToAssetId,
      int? transferFee,
      String? note,
      String? description,
      String? merchant,
      String? incomeSource,
      String? recurringRuleId,
      bool aiGenerated,
      String? aiInputType,
      TransactionStatus status,
      DateTime createdAt,
      DateTime? deletedAt,
      @JsonKey(includeFromJson: true, includeToJson: false) Category? category,
      @JsonKey(includeFromJson: true, includeToJson: false) Asset? asset,
      @JsonKey(includeFromJson: true, includeToJson: false)
      Asset? transferToAsset,
      @JsonKey(includeFromJson: true, includeToJson: false)
      List<TransactionAttachment>? attachments});

  $CategoryCopyWith<$Res>? get category;
  $AssetCopyWith<$Res>? get asset;
  $AssetCopyWith<$Res>? get transferToAsset;
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amount = null,
    Object? transactionDate = null,
    Object? categoryId = freezed,
    Object? assetId = null,
    Object? transferToAssetId = freezed,
    Object? transferFee = freezed,
    Object? note = freezed,
    Object? description = freezed,
    Object? merchant = freezed,
    Object? incomeSource = freezed,
    Object? recurringRuleId = freezed,
    Object? aiGenerated = null,
    Object? aiInputType = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? deletedAt = freezed,
    Object? category = freezed,
    Object? asset = freezed,
    Object? transferToAsset = freezed,
    Object? attachments = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      transactionDate: null == transactionDate
          ? _value.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      assetId: null == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String,
      transferToAssetId: freezed == transferToAssetId
          ? _value.transferToAssetId
          : transferToAssetId // ignore: cast_nullable_to_non_nullable
              as String?,
      transferFee: freezed == transferFee
          ? _value.transferFee
          : transferFee // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      merchant: freezed == merchant
          ? _value.merchant
          : merchant // ignore: cast_nullable_to_non_nullable
              as String?,
      incomeSource: freezed == incomeSource
          ? _value.incomeSource
          : incomeSource // ignore: cast_nullable_to_non_nullable
              as String?,
      recurringRuleId: freezed == recurringRuleId
          ? _value.recurringRuleId
          : recurringRuleId // ignore: cast_nullable_to_non_nullable
              as String?,
      aiGenerated: null == aiGenerated
          ? _value.aiGenerated
          : aiGenerated // ignore: cast_nullable_to_non_nullable
              as bool,
      aiInputType: freezed == aiInputType
          ? _value.aiInputType
          : aiInputType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TransactionStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category?,
      asset: freezed == asset
          ? _value.asset
          : asset // ignore: cast_nullable_to_non_nullable
              as Asset?,
      transferToAsset: freezed == transferToAsset
          ? _value.transferToAsset
          : transferToAsset // ignore: cast_nullable_to_non_nullable
              as Asset?,
      attachments: freezed == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<TransactionAttachment>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $CategoryCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AssetCopyWith<$Res>? get asset {
    if (_value.asset == null) {
      return null;
    }

    return $AssetCopyWith<$Res>(_value.asset!, (value) {
      return _then(_value.copyWith(asset: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AssetCopyWith<$Res>? get transferToAsset {
    if (_value.transferToAsset == null) {
      return null;
    }

    return $AssetCopyWith<$Res>(_value.transferToAsset!, (value) {
      return _then(_value.copyWith(transferToAsset: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      TransactionType type,
      int amount,
      DateTime transactionDate,
      String? categoryId,
      String assetId,
      String? transferToAssetId,
      int? transferFee,
      String? note,
      String? description,
      String? merchant,
      String? incomeSource,
      String? recurringRuleId,
      bool aiGenerated,
      String? aiInputType,
      TransactionStatus status,
      DateTime createdAt,
      DateTime? deletedAt,
      @JsonKey(includeFromJson: true, includeToJson: false) Category? category,
      @JsonKey(includeFromJson: true, includeToJson: false) Asset? asset,
      @JsonKey(includeFromJson: true, includeToJson: false)
      Asset? transferToAsset,
      @JsonKey(includeFromJson: true, includeToJson: false)
      List<TransactionAttachment>? attachments});

  @override
  $CategoryCopyWith<$Res>? get category;
  @override
  $AssetCopyWith<$Res>? get asset;
  @override
  $AssetCopyWith<$Res>? get transferToAsset;
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amount = null,
    Object? transactionDate = null,
    Object? categoryId = freezed,
    Object? assetId = null,
    Object? transferToAssetId = freezed,
    Object? transferFee = freezed,
    Object? note = freezed,
    Object? description = freezed,
    Object? merchant = freezed,
    Object? incomeSource = freezed,
    Object? recurringRuleId = freezed,
    Object? aiGenerated = null,
    Object? aiInputType = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? deletedAt = freezed,
    Object? category = freezed,
    Object? asset = freezed,
    Object? transferToAsset = freezed,
    Object? attachments = freezed,
  }) {
    return _then(_$TransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      transactionDate: null == transactionDate
          ? _value.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      assetId: null == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String,
      transferToAssetId: freezed == transferToAssetId
          ? _value.transferToAssetId
          : transferToAssetId // ignore: cast_nullable_to_non_nullable
              as String?,
      transferFee: freezed == transferFee
          ? _value.transferFee
          : transferFee // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      merchant: freezed == merchant
          ? _value.merchant
          : merchant // ignore: cast_nullable_to_non_nullable
              as String?,
      incomeSource: freezed == incomeSource
          ? _value.incomeSource
          : incomeSource // ignore: cast_nullable_to_non_nullable
              as String?,
      recurringRuleId: freezed == recurringRuleId
          ? _value.recurringRuleId
          : recurringRuleId // ignore: cast_nullable_to_non_nullable
              as String?,
      aiGenerated: null == aiGenerated
          ? _value.aiGenerated
          : aiGenerated // ignore: cast_nullable_to_non_nullable
              as bool,
      aiInputType: freezed == aiInputType
          ? _value.aiInputType
          : aiInputType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TransactionStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category?,
      asset: freezed == asset
          ? _value.asset
          : asset // ignore: cast_nullable_to_non_nullable
              as Asset?,
      transferToAsset: freezed == transferToAsset
          ? _value.transferToAsset
          : transferToAsset // ignore: cast_nullable_to_non_nullable
              as Asset?,
      attachments: freezed == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<TransactionAttachment>?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.amount,
      required this.transactionDate,
      this.categoryId,
      required this.assetId,
      this.transferToAssetId,
      this.transferFee,
      this.note,
      this.description,
      this.merchant,
      this.incomeSource,
      this.recurringRuleId,
      required this.aiGenerated,
      this.aiInputType,
      required this.status,
      required this.createdAt,
      this.deletedAt,
      @JsonKey(includeFromJson: true, includeToJson: false) this.category,
      @JsonKey(includeFromJson: true, includeToJson: false) this.asset,
      @JsonKey(includeFromJson: true, includeToJson: false)
      this.transferToAsset,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final List<TransactionAttachment>? attachments})
      : _attachments = attachments;

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final TransactionType type;
  @override
  final int amount;
  @override
  final DateTime transactionDate;
  @override
  final String? categoryId;
  @override
  final String assetId;
  @override
  final String? transferToAssetId;
  @override
  final int? transferFee;
  @override
  final String? note;
  @override
  final String? description;
  @override
  final String? merchant;
  @override
  final String? incomeSource;
  @override
  final String? recurringRuleId;
  @override
  final bool aiGenerated;
  @override
  final String? aiInputType;
  @override
  final TransactionStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? deletedAt;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final Category? category;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final Asset? asset;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final Asset? transferToAsset;
// ignore: invalid_annotation_target
  final List<TransactionAttachment>? _attachments;
// ignore: invalid_annotation_target
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  List<TransactionAttachment>? get attachments {
    final value = _attachments;
    if (value == null) return null;
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Transaction(id: $id, userId: $userId, type: $type, amount: $amount, transactionDate: $transactionDate, categoryId: $categoryId, assetId: $assetId, transferToAssetId: $transferToAssetId, transferFee: $transferFee, note: $note, description: $description, merchant: $merchant, incomeSource: $incomeSource, recurringRuleId: $recurringRuleId, aiGenerated: $aiGenerated, aiInputType: $aiInputType, status: $status, createdAt: $createdAt, deletedAt: $deletedAt, category: $category, asset: $asset, transferToAsset: $transferToAsset, attachments: $attachments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.assetId, assetId) || other.assetId == assetId) &&
            (identical(other.transferToAssetId, transferToAssetId) ||
                other.transferToAssetId == transferToAssetId) &&
            (identical(other.transferFee, transferFee) ||
                other.transferFee == transferFee) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.merchant, merchant) ||
                other.merchant == merchant) &&
            (identical(other.incomeSource, incomeSource) ||
                other.incomeSource == incomeSource) &&
            (identical(other.recurringRuleId, recurringRuleId) ||
                other.recurringRuleId == recurringRuleId) &&
            (identical(other.aiGenerated, aiGenerated) ||
                other.aiGenerated == aiGenerated) &&
            (identical(other.aiInputType, aiInputType) ||
                other.aiInputType == aiInputType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.asset, asset) || other.asset == asset) &&
            (identical(other.transferToAsset, transferToAsset) ||
                other.transferToAsset == transferToAsset) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        type,
        amount,
        transactionDate,
        categoryId,
        assetId,
        transferToAssetId,
        transferFee,
        note,
        description,
        merchant,
        incomeSource,
        recurringRuleId,
        aiGenerated,
        aiInputType,
        status,
        createdAt,
        deletedAt,
        category,
        asset,
        transferToAsset,
        const DeepCollectionEquality().hash(_attachments)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String id,
      required final String userId,
      required final TransactionType type,
      required final int amount,
      required final DateTime transactionDate,
      final String? categoryId,
      required final String assetId,
      final String? transferToAssetId,
      final int? transferFee,
      final String? note,
      final String? description,
      final String? merchant,
      final String? incomeSource,
      final String? recurringRuleId,
      required final bool aiGenerated,
      final String? aiInputType,
      required final TransactionStatus status,
      required final DateTime createdAt,
      final DateTime? deletedAt,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final Category? category,
      @JsonKey(includeFromJson: true, includeToJson: false) final Asset? asset,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final Asset? transferToAsset,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final List<TransactionAttachment>? attachments}) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  TransactionType get type;
  @override
  int get amount;
  @override
  DateTime get transactionDate;
  @override
  String? get categoryId;
  @override
  String get assetId;
  @override
  String? get transferToAssetId;
  @override
  int? get transferFee;
  @override
  String? get note;
  @override
  String? get description;
  @override
  String? get merchant;
  @override
  String? get incomeSource;
  @override
  String? get recurringRuleId;
  @override
  bool get aiGenerated;
  @override
  String? get aiInputType;
  @override
  TransactionStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime? get deletedAt;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeFromJson: true, includeToJson: false)
  Category? get category;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeFromJson: true, includeToJson: false)
  Asset? get asset;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeFromJson: true, includeToJson: false)
  Asset? get transferToAsset;
  @override // ignore: invalid_annotation_target
  @JsonKey(includeFromJson: true, includeToJson: false)
  List<TransactionAttachment>? get attachments;
  @override
  @JsonKey(ignore: true)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
