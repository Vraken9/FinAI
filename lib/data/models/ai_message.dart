import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_message.freezed.dart';
part 'ai_message.g.dart';

@freezed
class AiMessage with _$AiMessage {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AiMessage({
    String? id,
    String? userId,
    required String role, // 'user' or 'assistant'
    required String content,
    String? inputType,
    String? conversationId,
    DateTime? createdAt,
  }) = _AiMessage;

  factory AiMessage.fromJson(Map<String, dynamic> json) => _$AiMessageFromJson(json);
}
