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
  String get userId => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get fileType => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  bool get isReceipt => throw _privateConstructorUsedError;
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
      String userId,
      String filePath,
      String fileName,
      String fileType,
      int fileSizeBytes,
      bool isReceipt,
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
    Object? userId = null,
    Object? filePath = null,
    Object? fileName = null,
    Object? fileType = null,
    Object? fileSizeBytes = null,
    Object? isReceipt = null,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileType: null == fileType
          ? _value.fileType
          : fileType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      isReceipt: null == isReceipt
          ? _value.isReceipt
          : isReceipt // ignore: cast_nullable_to_non_nullable
              as bool,
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
      String userId,
      String filePath,
      String fileName,
      String fileType,
      int fileSizeBytes,
      bool isReceipt,
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
    Object? userId = null,
    Object? filePath = null,
    Object? fileName = null,
    Object? fileType = null,
    Object? fileSizeBytes = null,
    Object? isReceipt = null,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileType: null == fileType
          ? _value.fileType
          : fileType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      isReceipt: null == isReceipt
          ? _value.isReceipt
          : isReceipt // ignore: cast_nullable_to_non_nullable
              as bool,
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
      required this.userId,
      required this.filePath,
      required this.fileName,
      required this.fileType,
      required this.fileSizeBytes,
      this.isReceipt = false,
      this.createdAt});

  factory _$TransactionAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionAttachmentImplFromJson(json);

  @override
  final String id;
  @override
  final String transactionId;
  @override
  final String userId;
  @override
  final String filePath;
  @override
  final String fileName;
  @override
  final String fileType;
  @override
  final int fileSizeBytes;
  @override
  @JsonKey()
  final bool isReceipt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TransactionAttachment(id: $id, transactionId: $transactionId, userId: $userId, filePath: $filePath, fileName: $fileName, fileType: $fileType, fileSizeBytes: $fileSizeBytes, isReceipt: $isReceipt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionAttachmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.isReceipt, isReceipt) ||
                other.isReceipt == isReceipt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, transactionId, userId,
      filePath, fileName, fileType, fileSizeBytes, isReceipt, createdAt);

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
      required final String userId,
      required final String filePath,
      required final String fileName,
      required final String fileType,
      required final int fileSizeBytes,
      final bool isReceipt,
      final DateTime? createdAt}) = _$TransactionAttachmentImpl;

  factory _TransactionAttachment.fromJson(Map<String, dynamic> json) =
      _$TransactionAttachmentImpl.fromJson;

  @override
  String get id;
  @override
  String get transactionId;
  @override
  String get userId;
  @override
  String get filePath;
  @override
  String get fileName;
  @override
  String get fileType;
  @override
  int get fileSizeBytes;
  @override
  bool get isReceipt;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$TransactionAttachmentImplCopyWith<_$TransactionAttachmentImpl>
      get copyWith => throw _privateConstructorUsedError;
}
