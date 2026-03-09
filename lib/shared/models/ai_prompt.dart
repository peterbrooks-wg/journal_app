import 'package:json_annotation/json_annotation.dart';

part 'ai_prompt.g.dart';

/// An AI-generated writing prompt for the user.
@JsonSerializable(fieldRename: FieldRename.snake)
class AiPrompt {
  final String id;
  final String userId;
  final String promptText;
  final List<String> sourceThemes;
  final bool used;
  final DateTime? usedAt;
  final DateTime createdAt;

  const AiPrompt({
    required this.id,
    required this.userId,
    required this.promptText,
    required this.sourceThemes,
    required this.used,
    this.usedAt,
    required this.createdAt,
  });

  factory AiPrompt.fromJson(Map<String, dynamic> json) =>
      _$AiPromptFromJson(json);

  Map<String, dynamic> toJson() => _$AiPromptToJson(this);
}
