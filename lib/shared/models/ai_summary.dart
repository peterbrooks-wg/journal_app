import 'package:json_annotation/json_annotation.dart';

part 'ai_summary.g.dart';

/// A weekly AI-generated summary of journal entries.
@JsonSerializable(fieldRename: FieldRename.snake)
class AiSummary {
  final String id;
  final String userId;
  final DateTime weekStart;
  final String summaryText;
  final List<String> themes;
  final int entryCount;
  final int wordCountTotal;
  final DateTime createdAt;

  const AiSummary({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.summaryText,
    required this.themes,
    required this.entryCount,
    required this.wordCountTotal,
    required this.createdAt,
  });

  factory AiSummary.fromJson(Map<String, dynamic> json) =>
      _$AiSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AiSummaryToJson(this);
}
