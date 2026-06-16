// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransactionAttachment _$TransactionAttachmentFromJson(
    Map<String, dynamic> json) {
  return _TransactionAttachment.fromJson(json);
}

/// @nodoc
mixin _$TransactionAttachment {
  String get id => throw _privateConstructorUsedError;
  String get transactionId => throw _privateConstructorUsedError;
  String get fileUrl => throw _privateConstructorUsedError;
  String get fileType => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionAttachmentCopyWith<TransactionAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionAttachmentCopyWith<$Res> {
  factory $TransactionAttachmentCopyWith(TransactionAttachment value,
          $Res Function(TransactionAttachment) then) =
      _$TransactionAttachmentCopyWithImpl<$Res, TransactionAttachment>;
  @useResult
  $Res call(
      {String id,
      String transactionId,
      String fileUrl,
      String fileType,
      DateTime? createdAt});
}

/// @nodoc
class _$TransactionAttachmentCopyWithImpl<$Res,
        $Val extends TransactionAttachment>
    implements $TransactionAttachmentCopyWith<$Res> {
  _$TransactionAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = null,
    Object? fileUrl = null,
    Object? fileType = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      fileType: null == fileType
          ? _value.fileType
          : fileType // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionAttachmentImplCopyWith<$Res>
    implements $TransactionAttachmentCopyWith<$Res> {
  factory _$$TransactionAttachmentImplCopyWith(
          _$TransactionAttachmentImpl value,
          $Res Function(_$TransactionAttachmentImpl) then) =
      __$$TransactionAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String transactionId,
      String fileUrl,
      String fileType,
      DateTime? createdAt});
}

/// @nodoc
class __$$TransactionAttachmentImplCopyWithImpl<$Res>
    extends _$TransactionAttachmentCopyWithImpl<$Res,
        _$TransactionAttachmentImpl>
    implements _$$TransactionAttachmentImplCopyWith<$Res> {
  __$$TransactionAttachmentImplCopyWithImpl(_$TransactionAttachmentImpl _value,
      $Res Function(_$TransactionAttachmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = null,
    Object? fileUrl = null,
    Object? fileType = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$TransactionAttachmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      fileType: null == fileType
          ? _value.fileType
          : fileType // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$TransactionAttachmentImpl implements _TransactionAttachment {
  const _$TransactionAttachmentImpl(
      {required this.id,
      required this.transactionId,
      required this.fileUrl,
      required this.fileType,
      this.createdAt});

  factory _$TransactionAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionAttachmentImplFromJson(json);

  @override
  final String id;
  @override
  final String transactionId;
  @override
  final String fileUrl;
  @override
  final String fileType;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TransactionAttachment(id: $id, transactionId: $transactionId, fileUrl: $fileUrl, fileType: $fileType, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionAttachmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, transactionId, fileUrl, fileType, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionAttachmentImplCopyWith<_$TransactionAttachmentImpl>
      get copyWith => __$$TransactionAttachmentImplCopyWithImpl<
          _$TransactionAttachmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionAttachmentImplToJson(
      this,
    );
  }
}

abstract class _TransactionAttachment implements TransactionAttachment {
  const factory _TransactionAttachment(
      {required final String id,
      required final String transactionId,
      required final String fileUrl,
      required final String fileType,
      final DateTime? createdAt}) = _$TransactionAttachmentImpl;

  factory _TransactionAttachment.fromJson(Map<String, dynamic> json) =
      _$TransactionAttachmentImpl.fromJson;

  @override
  String get id;
  @override
  String get transactionId;
  @override
  String get fileUrl;
  @override
  String get fileType;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$TransactionAttachmentImplCopyWith<_$TransactionAttachmentImpl>
      get copyWith => throw _privateConstructorUsedError;
}
