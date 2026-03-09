import 'package:json_annotation/json_annotation.dart';

part 'running_summary.g.dart';

/// Rolling compressed summary for progressive AI summarization.
@JsonSerializable(fieldRename: FieldRename.snake)
class RunningSummary {
  final String userId;
  final String summaryText;
  final String? lastEntryId;
  final DateTime updatedAt;

  const RunningSummary({
    required this.userId,
    required this.summaryText,
    this.lastEntryId,
    required this.updatedAt,
  });

  factory RunningSummary.fromJson(Map<String, dynamic> json) =>
      _$RunningSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$RunningSummaryToJson(this);
}
