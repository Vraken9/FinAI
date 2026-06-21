// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiMessageImpl _$$AiMessageImplFromJson(Map<String, dynamic> json) =>
    _$AiMessageImpl(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      role: json['role'] as String,
      content: json['content'] as String,
      inputType: json['input_type'] as String?,
      conversationId: json['conversation_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$AiMessageImplToJson(_$AiMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'role': instance.role,
      'content': instance.content,
      'input_type': instance.inputType,
      'conversation_id': instance.conversationId,
      'created_at': instance.createdAt?.toIso8601String(),
    };
