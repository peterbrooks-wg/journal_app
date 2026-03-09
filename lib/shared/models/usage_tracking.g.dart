// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_tracking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageTracking _$UsageTrackingFromJson(Map<String, dynamic> json) =>
    UsageTracking(
      userId: json['user_id'] as String,
      month: DateTime.parse(json['month'] as String),
      aiPromptRequests: (json['ai_prompt_requests'] as num).toInt(),
      summaryCount: (json['summary_count'] as num).toInt(),
    );

Map<String, dynamic> _$UsageTrackingToJson(UsageTracking instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'month': instance.month.toIso8601String(),
      'ai_prompt_requests': instance.aiPromptRequests,
      'summary_count': instance.summaryCount,
    };
