// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_prompt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiPrompt _$AiPromptFromJson(Map<String, dynamic> json) => AiPrompt(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  summaryId: json['summary_id'] as String,
  promptText: json['prompt_text'] as String,
  sourceThemes: (json['source_themes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  used: json['used'] as bool,
  usedAt: json['used_at'] == null
      ? null
      : DateTime.parse(json['used_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AiPromptToJson(AiPrompt instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'summary_id': instance.summaryId,
  'prompt_text': instance.promptText,
  'source_themes': instance.sourceThemes,
  'used': instance.used,
  'used_at': instance.usedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};
