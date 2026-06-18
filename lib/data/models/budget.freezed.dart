// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Budget _$BudgetFromJson(Map<String, dynamic> json) {
  return _Budget.fromJson(json);
}

/// @nodoc
mixin _$Budget {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  int get periodMonth => throw _privateConstructorUsedError;
  int get periodYear => throw _privateConstructorUsedError;
  bool get carryOver => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError; // View fields
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get categoryName => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get categoryIcon => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get categoryColor => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: true, includeToJson: false)
  int? get spentAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BudgetCopyWith<Budget> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetCopyWith<$Res> {
  factory $BudgetCopyWith(Budget value, $Res Function(Budget) then) =
      _$BudgetCopyWithImpl<$Res, Budget>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String categoryId,
      int amount,
      int periodMonth,
      int periodYear,
      bool carryOver,
      DateTime? createdAt,
      DateTime? updatedAt,
      @JsonKey(includeFromJson: true, includeToJson: false)
      String? categoryName,
      @JsonKey(includeFromJson: true, includeToJson: false)
      String? categoryIcon,
      @JsonKey(includeFromJson: true, includeToJson: false)
      String? categoryColor,
      @JsonKey(includeFromJson: true, includeToJson: false) int? spentAmount});
}

/// @nodoc
class _$BudgetCopyWithImpl<$Res, $Val extends Budget>
    implements $BudgetCopyWith<$Res> {
  _$BudgetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? categoryId = null,
    Object? amount = null,
    Object? periodMonth = null,
    Object? periodYear = null,
    Object? carryOver = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? categoryName = freezed,
    Object? categoryIcon = freezed,
    Object? categoryColor = freezed,
    Object? spentAmount = freezed,
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
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      periodMonth: null == periodMonth
          ? _value.periodMonth
          : periodMonth // ignore: cast_nullable_to_non_nullable
              as int,
      periodYear: null == periodYear
          ? _value.periodYear
          : periodYear // ignore: cast_nullable_to_non_nullable
              as int,
      carryOver: null == carryOver
          ? _value.carryOver
          : carryOver // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryIcon: freezed == categoryIcon
          ? _value.categoryIcon
          : categoryIcon // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryColor: freezed == categoryColor
          ? _value.categoryColor
          : categoryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      spentAmount: freezed == spentAmount
          ? _value.spentAmount
          : spentAmount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BudgetImplCopyWith<$Res> implements $BudgetCopyWith<$Res> {
  factory _$$BudgetImplCopyWith(
          _$BudgetImpl value, $Res Function(_$BudgetImpl) then) =
      __$$BudgetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String categoryId,
      int amount,
      int periodMonth,
      int periodYear,
      bool carryOver,
      DateTime? createdAt,
      DateTime? updatedAt,
      @JsonKey(includeFromJson: true, includeToJson: false)
      String? categoryName,
      @JsonKey(includeFromJson: true, includeToJson: false)
      String? categoryIcon,
      @JsonKey(includeFromJson: true, includeToJson: false)
      String? categoryColor,
      @JsonKey(includeFromJson: true, includeToJson: false) int? spentAmount});
}

/// @nodoc
class __$$BudgetImplCopyWithImpl<$Res>
    extends _$BudgetCopyWithImpl<$Res, _$BudgetImpl>
    implements _$$BudgetImplCopyWith<$Res> {
  __$$BudgetImplCopyWithImpl(
      _$BudgetImpl _value, $Res Function(_$BudgetImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? categoryId = null,
    Object? amount = null,
    Object? periodMonth = null,
    Object? periodYear = null,
    Object? carryOver = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? categoryName = freezed,
    Object? categoryIcon = freezed,
    Object? categoryColor = freezed,
    Object? spentAmount = freezed,
  }) {
    return _then(_$BudgetImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      periodMonth: null == periodMonth
          ? _value.periodMonth
          : periodMonth // ignore: cast_nullable_to_non_nullable
              as int,
      periodYear: null == periodYear
          ? _value.periodYear
          : periodYear // ignore: cast_nullable_to_non_nullable
              as int,
      carryOver: null == carryOver
          ? _value.carryOver
          : carryOver // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryIcon: freezed == categoryIcon
          ? _value.categoryIcon
          : categoryIcon // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryColor: freezed == categoryColor
          ? _value.categoryColor
          : categoryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      spentAmount: freezed == spentAmount
          ? _value.spentAmount
          : spentAmount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$BudgetImpl implements _Budget {
  const _$BudgetImpl(
      {required this.id,
      required this.userId,
      required this.categoryId,
      required this.amount,
      required this.periodMonth,
      required this.periodYear,
      this.carryOver = false,
      this.createdAt,
      this.updatedAt,
      @JsonKey(includeFromJson: true, includeToJson: false) this.categoryName,
      @JsonKey(includeFromJson: true, includeToJson: false) this.categoryIcon,
      @JsonKey(includeFromJson: true, includeToJson: false) this.categoryColor,
      @JsonKey(includeFromJson: true, includeToJson: false) this.spentAmount});

  factory _$BudgetImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String categoryId;
  @override
  final int amount;
  @override
  final int periodMonth;
  @override
  final int periodYear;
  @override
  @JsonKey()
  final bool carryOver;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
// View fields
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String? categoryName;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String? categoryIcon;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String? categoryColor;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final int? spentAmount;

  @override
  String toString() {
    return 'Budget(id: $id, userId: $userId, categoryId: $categoryId, amount: $amount, periodMonth: $periodMonth, periodYear: $periodYear, carryOver: $carryOver, createdAt: $createdAt, updatedAt: $updatedAt, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryColor: $categoryColor, spentAmount: $spentAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.periodMonth, periodMonth) ||
                other.periodMonth == periodMonth) &&
            (identical(other.periodYear, periodYear) ||
                other.periodYear == periodYear) &&
            (identical(other.carryOver, carryOver) ||
                other.carryOver == carryOver) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.categoryIcon, categoryIcon) ||
                other.categoryIcon == categoryIcon) &&
            (identical(other.categoryColor, categoryColor) ||
                other.categoryColor == categoryColor) &&
            (identical(other.spentAmount, spentAmount) ||
                other.spentAmount == spentAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      categoryId,
      amount,
      periodMonth,
      periodYear,
      carryOver,
      createdAt,
      updatedAt,
      categoryName,
      categoryIcon,
      categoryColor,
      spentAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetImplCopyWith<_$BudgetImpl> get copyWith =>
      __$$BudgetImplCopyWithImpl<_$BudgetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetImplToJson(
      this,
    );
  }
}

abstract class _Budget implements Budget {
  const factory _Budget(
      {required final String id,
      required final String userId,
      required final String categoryId,
      required final int amount,
      required final int periodMonth,
      required final int periodYear,
      final bool carryOver,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final String? categoryName,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final String? categoryIcon,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final String? categoryColor,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final int? spentAmount}) = _$BudgetImpl;

  factory _Budget.fromJson(Map<String, dynamic> json) = _$BudgetImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get categoryId;
  @override
  int get amount;
  @override
  int get periodMonth;
  @override
  int get periodYear;
  @override
  bool get carryOver;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override // View fields
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get categoryName;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get categoryIcon;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get categoryColor;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  int? get spentAmount;
  @override
  @JsonKey(ignore: true)
  _$$BudgetImplCopyWith<_$BudgetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
