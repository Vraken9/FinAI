// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecurringRule _$RecurringRuleFromJson(Map<String, dynamic> json) {
  return _RecurringRule.fromJson(json);
}

/// @nodoc
mixin _$RecurringRule {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_type')
  String get transactionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  int get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'asset_id')
  String get assetId => throw _privateConstructorUsedError;
  @JsonKey(name: 'transfer_to_asset_id')
  String? get transferToAssetId => throw _privateConstructorUsedError;
  @JsonKey(name: 'note')
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'merchant')
  String? get merchant => throw _privateConstructorUsedError;
  @JsonKey(name: 'frequency')
  RecurringFrequency get frequency => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_month')
  int? get dayOfMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_week')
  int? get dayOfWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_due_date')
  DateTime get nextDueDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_generated_at')
  DateTime? get lastGeneratedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecurringRuleCopyWith<RecurringRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurringRuleCopyWith<$Res> {
  factory $RecurringRuleCopyWith(
          RecurringRule value, $Res Function(RecurringRule) then) =
      _$RecurringRuleCopyWithImpl<$Res, RecurringRule>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'transaction_type') String transactionType,
      @JsonKey(name: 'amount') int amount,
      @JsonKey(name: 'category_id') String categoryId,
      @JsonKey(name: 'asset_id') String assetId,
      @JsonKey(name: 'transfer_to_asset_id') String? transferToAssetId,
      @JsonKey(name: 'note') String? note,
      @JsonKey(name: 'description') String? description,
      @JsonKey(name: 'merchant') String? merchant,
      @JsonKey(name: 'frequency') RecurringFrequency frequency,
      @JsonKey(name: 'day_of_month') int? dayOfMonth,
      @JsonKey(name: 'day_of_week') int? dayOfWeek,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime? endDate,
      @JsonKey(name: 'next_due_date') DateTime nextDueDate,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'last_generated_at') DateTime? lastGeneratedAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'deleted_at') DateTime? deletedAt});
}

/// @nodoc
class _$RecurringRuleCopyWithImpl<$Res, $Val extends RecurringRule>
    implements $RecurringRuleCopyWith<$Res> {
  _$RecurringRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? transactionType = null,
    Object? amount = null,
    Object? categoryId = null,
    Object? assetId = null,
    Object? transferToAssetId = freezed,
    Object? note = freezed,
    Object? description = freezed,
    Object? merchant = freezed,
    Object? frequency = null,
    Object? dayOfMonth = freezed,
    Object? dayOfWeek = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? nextDueDate = null,
    Object? isActive = null,
    Object? lastGeneratedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
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
      transactionType: null == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      assetId: null == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String,
      transferToAssetId: freezed == transferToAssetId
          ? _value.transferToAssetId
          : transferToAssetId // ignore: cast_nullable_to_non_nullable
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
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as RecurringFrequency,
      dayOfMonth: freezed == dayOfMonth
          ? _value.dayOfMonth
          : dayOfMonth // ignore: cast_nullable_to_non_nullable
              as int?,
      dayOfWeek: freezed == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextDueDate: null == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastGeneratedAt: freezed == lastGeneratedAt
          ? _value.lastGeneratedAt
          : lastGeneratedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecurringRuleImplCopyWith<$Res>
    implements $RecurringRuleCopyWith<$Res> {
  factory _$$RecurringRuleImplCopyWith(
          _$RecurringRuleImpl value, $Res Function(_$RecurringRuleImpl) then) =
      __$$RecurringRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'transaction_type') String transactionType,
      @JsonKey(name: 'amount') int amount,
      @JsonKey(name: 'category_id') String categoryId,
      @JsonKey(name: 'asset_id') String assetId,
      @JsonKey(name: 'transfer_to_asset_id') String? transferToAssetId,
      @JsonKey(name: 'note') String? note,
      @JsonKey(name: 'description') String? description,
      @JsonKey(name: 'merchant') String? merchant,
      @JsonKey(name: 'frequency') RecurringFrequency frequency,
      @JsonKey(name: 'day_of_month') int? dayOfMonth,
      @JsonKey(name: 'day_of_week') int? dayOfWeek,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime? endDate,
      @JsonKey(name: 'next_due_date') DateTime nextDueDate,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'last_generated_at') DateTime? lastGeneratedAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'deleted_at') DateTime? deletedAt});
}

/// @nodoc
class __$$RecurringRuleImplCopyWithImpl<$Res>
    extends _$RecurringRuleCopyWithImpl<$Res, _$RecurringRuleImpl>
    implements _$$RecurringRuleImplCopyWith<$Res> {
  __$$RecurringRuleImplCopyWithImpl(
      _$RecurringRuleImpl _value, $Res Function(_$RecurringRuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? transactionType = null,
    Object? amount = null,
    Object? categoryId = null,
    Object? assetId = null,
    Object? transferToAssetId = freezed,
    Object? note = freezed,
    Object? description = freezed,
    Object? merchant = freezed,
    Object? frequency = null,
    Object? dayOfMonth = freezed,
    Object? dayOfWeek = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? nextDueDate = null,
    Object? isActive = null,
    Object? lastGeneratedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(_$RecurringRuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionType: null == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      assetId: null == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String,
      transferToAssetId: freezed == transferToAssetId
          ? _value.transferToAssetId
          : transferToAssetId // ignore: cast_nullable_to_non_nullable
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
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as RecurringFrequency,
      dayOfMonth: freezed == dayOfMonth
          ? _value.dayOfMonth
          : dayOfMonth // ignore: cast_nullable_to_non_nullable
              as int?,
      dayOfWeek: freezed == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextDueDate: null == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastGeneratedAt: freezed == lastGeneratedAt
          ? _value.lastGeneratedAt
          : lastGeneratedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurringRuleImpl implements _RecurringRule {
  const _$RecurringRuleImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'transaction_type') required this.transactionType,
      @JsonKey(name: 'amount') required this.amount,
      @JsonKey(name: 'category_id') required this.categoryId,
      @JsonKey(name: 'asset_id') required this.assetId,
      @JsonKey(name: 'transfer_to_asset_id') this.transferToAssetId,
      @JsonKey(name: 'note') this.note,
      @JsonKey(name: 'description') this.description,
      @JsonKey(name: 'merchant') this.merchant,
      @JsonKey(name: 'frequency') required this.frequency,
      @JsonKey(name: 'day_of_month') this.dayOfMonth,
      @JsonKey(name: 'day_of_week') this.dayOfWeek,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      @JsonKey(name: 'next_due_date') required this.nextDueDate,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'last_generated_at') this.lastGeneratedAt,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'deleted_at') this.deletedAt});

  factory _$RecurringRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurringRuleImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'transaction_type')
  final String transactionType;
  @override
  @JsonKey(name: 'amount')
  final int amount;
  @override
  @JsonKey(name: 'category_id')
  final String categoryId;
  @override
  @JsonKey(name: 'asset_id')
  final String assetId;
  @override
  @JsonKey(name: 'transfer_to_asset_id')
  final String? transferToAssetId;
  @override
  @JsonKey(name: 'note')
  final String? note;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'merchant')
  final String? merchant;
  @override
  @JsonKey(name: 'frequency')
  final RecurringFrequency frequency;
  @override
  @JsonKey(name: 'day_of_month')
  final int? dayOfMonth;
  @override
  @JsonKey(name: 'day_of_week')
  final int? dayOfWeek;
  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @JsonKey(name: 'next_due_date')
  final DateTime nextDueDate;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'last_generated_at')
  final DateTime? lastGeneratedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'RecurringRule(id: $id, userId: $userId, transactionType: $transactionType, amount: $amount, categoryId: $categoryId, assetId: $assetId, transferToAssetId: $transferToAssetId, note: $note, description: $description, merchant: $merchant, frequency: $frequency, dayOfMonth: $dayOfMonth, dayOfWeek: $dayOfWeek, startDate: $startDate, endDate: $endDate, nextDueDate: $nextDueDate, isActive: $isActive, lastGeneratedAt: $lastGeneratedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurringRuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.assetId, assetId) || other.assetId == assetId) &&
            (identical(other.transferToAssetId, transferToAssetId) ||
                other.transferToAssetId == transferToAssetId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.merchant, merchant) ||
                other.merchant == merchant) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.nextDueDate, nextDueDate) ||
                other.nextDueDate == nextDueDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.lastGeneratedAt, lastGeneratedAt) ||
                other.lastGeneratedAt == lastGeneratedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        transactionType,
        amount,
        categoryId,
        assetId,
        transferToAssetId,
        note,
        description,
        merchant,
        frequency,
        dayOfMonth,
        dayOfWeek,
        startDate,
        endDate,
        nextDueDate,
        isActive,
        lastGeneratedAt,
        createdAt,
        updatedAt,
        deletedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurringRuleImplCopyWith<_$RecurringRuleImpl> get copyWith =>
      __$$RecurringRuleImplCopyWithImpl<_$RecurringRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurringRuleImplToJson(
      this,
    );
  }
}

abstract class _RecurringRule implements RecurringRule {
  const factory _RecurringRule(
      {@JsonKey(name: 'id') required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'transaction_type') required final String transactionType,
      @JsonKey(name: 'amount') required final int amount,
      @JsonKey(name: 'category_id') required final String categoryId,
      @JsonKey(name: 'asset_id') required final String assetId,
      @JsonKey(name: 'transfer_to_asset_id') final String? transferToAssetId,
      @JsonKey(name: 'note') final String? note,
      @JsonKey(name: 'description') final String? description,
      @JsonKey(name: 'merchant') final String? merchant,
      @JsonKey(name: 'frequency') required final RecurringFrequency frequency,
      @JsonKey(name: 'day_of_month') final int? dayOfMonth,
      @JsonKey(name: 'day_of_week') final int? dayOfWeek,
      @JsonKey(name: 'start_date') required final DateTime startDate,
      @JsonKey(name: 'end_date') final DateTime? endDate,
      @JsonKey(name: 'next_due_date') required final DateTime nextDueDate,
      @JsonKey(name: 'is_active') final bool isActive,
      @JsonKey(name: 'last_generated_at') final DateTime? lastGeneratedAt,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'deleted_at')
      final DateTime? deletedAt}) = _$RecurringRuleImpl;

  factory _RecurringRule.fromJson(Map<String, dynamic> json) =
      _$RecurringRuleImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'transaction_type')
  String get transactionType;
  @override
  @JsonKey(name: 'amount')
  int get amount;
  @override
  @JsonKey(name: 'category_id')
  String get categoryId;
  @override
  @JsonKey(name: 'asset_id')
  String get assetId;
  @override
  @JsonKey(name: 'transfer_to_asset_id')
  String? get transferToAssetId;
  @override
  @JsonKey(name: 'note')
  String? get note;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'merchant')
  String? get merchant;
  @override
  @JsonKey(name: 'frequency')
  RecurringFrequency get frequency;
  @override
  @JsonKey(name: 'day_of_month')
  int? get dayOfMonth;
  @override
  @JsonKey(name: 'day_of_week')
  int? get dayOfWeek;
  @override
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'next_due_date')
  DateTime get nextDueDate;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'last_generated_at')
  DateTime? get lastGeneratedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt;
  @override
  @JsonKey(ignore: true)
  _$$RecurringRuleImplCopyWith<_$RecurringRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
