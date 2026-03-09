// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'running_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunningSummary _$RunningSummaryFromJson(Map<String, dynamic> json) =>
    RunningSummary(
      userId: json['user_id'] as String,
      summaryText: json['summary_text'] as String,
      lastEntryId: json['last_entry_id'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$RunningSummaryToJson(RunningSummary instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'summary_text': instance.summaryText,
      'last_entry_id': instance.lastEntryId,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
