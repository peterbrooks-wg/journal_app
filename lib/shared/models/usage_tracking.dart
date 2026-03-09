import 'package:json_annotation/json_annotation.dart';

part 'usage_tracking.g.dart';

/// Monthly AI usage tracking per user for rate limiting.
@JsonSerializable(fieldRename: FieldRename.snake)
class UsageTracking {
  final String userId;
  final DateTime month;
  final int aiPromptRequests;
  final int summaryCount;

  const UsageTracking({
    required this.userId,
    required this.month,
    required this.aiPromptRequests,
    required this.summaryCount,
  });

  factory UsageTracking.fromJson(Map<String, dynamic> json) =>
      _$UsageTrackingFromJson(json);

  Map<String, dynamic> toJson() => _$UsageTrackingToJson(this);
}
