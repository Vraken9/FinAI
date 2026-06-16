// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ParsedTransaction _$ParsedTransactionFromJson(Map<String, dynamic> json) {
  return _ParsedTransaction.fromJson(json);
}

/// @nodoc
mixin _$ParsedTransaction {
  String? get type => throw _privateConstructorUsedError;
  int? get amount => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String? get assetId => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get merchant => throw _privateConstructorUsedError;
  String? get transactionDate => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;
  String? get aiRawInput => throw _privateConstructorUsedError;
  String? get pendingAttachmentPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ParsedTransactionCopyWith<ParsedTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParsedTransactionCopyWith<$Res> {
  factory $ParsedTransactionCopyWith(
          ParsedTransaction value, $Res Function(ParsedTransaction) then) =
      _$ParsedTransactionCopyWithImpl<$Res, ParsedTransaction>;
  @useResult
  $Res call(
      {String? type,
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
      String? pendingAttachmentPath});
}

/// @nodoc
class _$ParsedTransactionCopyWithImpl<$Res, $Val extends ParsedTransaction>
    implements $ParsedTransactionCopyWith<$Res> {
  _$ParsedTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? amount = freezed,
    Object? date = freezed,
    Object? categoryName = freezed,
    Object? categoryId = freezed,
    Object? assetId = freezed,
    Object? note = freezed,
    Object? description = freezed,
    Object? merchant = freezed,
    Object? transactionDate = freezed,
    Object? confidence = freezed,
    Object? aiRawInput = freezed,
    Object? pendingAttachmentPath = freezed,
  }) {
    return _then(_value.copyWith(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      assetId: freezed == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      transactionDate: freezed == transactionDate
          ? _value.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: freezed == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      aiRawInput: freezed == aiRawInput
          ? _value.aiRawInput
          : aiRawInput // ignore: cast_nullable_to_non_nullable
              as String?,
      pendingAttachmentPath: freezed == pendingAttachmentPath
          ? _value.pendingAttachmentPath
          : pendingAttachmentPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ParsedTransactionImplCopyWith<$Res>
    implements $ParsedTransactionCopyWith<$Res> {
  factory _$$ParsedTransactionImplCopyWith(_$ParsedTransactionImpl value,
          $Res Function(_$ParsedTransactionImpl) then) =
      __$$ParsedTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? type,
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
      String? pendingAttachmentPath});
}

/// @nodoc
class __$$ParsedTransactionImplCopyWithImpl<$Res>
    extends _$ParsedTransactionCopyWithImpl<$Res, _$ParsedTransactionImpl>
    implements _$$ParsedTransactionImplCopyWith<$Res> {
  __$$ParsedTransactionImplCopyWithImpl(_$ParsedTransactionImpl _value,
      $Res Function(_$ParsedTransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? amount = freezed,
    Object? date = freezed,
    Object? categoryName = freezed,
    Object? categoryId = freezed,
    Object? assetId = freezed,
    Object? note = freezed,
    Object? description = freezed,
    Object? merchant = freezed,
    Object? transactionDate = freezed,
    Object? confidence = freezed,
    Object? aiRawInput = freezed,
    Object? pendingAttachmentPath = freezed,
  }) {
    return _then(_$ParsedTransactionImpl(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      assetId: freezed == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      transactionDate: freezed == transactionDate
          ? _value.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: freezed == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      aiRawInput: freezed == aiRawInput
          ? _value.aiRawInput
          : aiRawInput // ignore: cast_nullable_to_non_nullable
              as String?,
      pendingAttachmentPath: freezed == pendingAttachmentPath
          ? _value.pendingAttachmentPath
          : pendingAttachmentPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ParsedTransactionImpl implements _ParsedTransaction {
  const _$ParsedTransactionImpl(
      {this.type,
      this.amount,
      this.date,
      this.categoryName,
      this.categoryId,
      this.assetId,
      this.note,
      this.description,
      this.merchant,
      this.transactionDate,
      this.confidence,
      this.aiRawInput,
      this.pendingAttachmentPath});

  factory _$ParsedTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParsedTransactionImplFromJson(json);

  @override
  final String? type;
  @override
  final int? amount;
  @override
  final String? date;
  @override
  final String? categoryName;
  @override
  final String? categoryId;
  @override
  final String? assetId;
  @override
  final String? note;
  @override
  final String? description;
  @override
  final String? merchant;
  @override
  final String? transactionDate;
  @override
  final double? confidence;
  @override
  final String? aiRawInput;
  @override
  final String? pendingAttachmentPath;

  @override
  String toString() {
    return 'ParsedTransaction(type: $type, amount: $amount, date: $date, categoryName: $categoryName, categoryId: $categoryId, assetId: $assetId, note: $note, description: $description, merchant: $merchant, transactionDate: $transactionDate, confidence: $confidence, aiRawInput: $aiRawInput, pendingAttachmentPath: $pendingAttachmentPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParsedTransactionImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.assetId, assetId) || other.assetId == assetId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.merchant, merchant) ||
                other.merchant == merchant) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.aiRawInput, aiRawInput) ||
                other.aiRawInput == aiRawInput) &&
            (identical(other.pendingAttachmentPath, pendingAttachmentPath) ||
                other.pendingAttachmentPath == pendingAttachmentPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      amount,
      date,
      categoryName,
      categoryId,
      assetId,
      note,
      description,
      merchant,
      transactionDate,
      confidence,
      aiRawInput,
      pendingAttachmentPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ParsedTransactionImplCopyWith<_$ParsedTransactionImpl> get copyWith =>
      __$$ParsedTransactionImplCopyWithImpl<_$ParsedTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParsedTransactionImplToJson(
      this,
    );
  }
}

abstract class _ParsedTransaction implements ParsedTransaction {
  const factory _ParsedTransaction(
      {final String? type,
      final int? amount,
      final String? date,
      final String? categoryName,
      final String? categoryId,
      final String? assetId,
      final String? note,
      final String? description,
      final String? merchant,
      final String? transactionDate,
      final double? confidence,
      final String? aiRawInput,
      final String? pendingAttachmentPath}) = _$ParsedTransactionImpl;

  factory _ParsedTransaction.fromJson(Map<String, dynamic> json) =
      _$ParsedTransactionImpl.fromJson;

  @override
  String? get type;
  @override
  int? get amount;
  @override
  String? get date;
  @override
  String? get categoryName;
  @override
  String? get categoryId;
  @override
  String? get assetId;
  @override
  String? get note;
  @override
  String? get description;
  @override
  String? get merchant;
  @override
  String? get transactionDate;
  @override
  double? get confidence;
  @override
  String? get aiRawInput;
  @override
  String? get pendingAttachmentPath;
  @override
  @JsonKey(ignore: true)
  _$$ParsedTransactionImplCopyWith<_$ParsedTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
