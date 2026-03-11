// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiSummary _$AiSummaryFromJson(Map<String, dynamic> json) => AiSummary(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  weekStart: DateTime.parse(json['week_start'] as String),
  summaryText: json['summary_text'] as String,
  growthObservation: json['growth_observation'] as String,
  themes: (json['themes'] as List<dynamic>).map((e) => e as String).toList(),
  entryCount: (json['entry_count'] as num).toInt(),
  wordCountTotal: (json['word_count_total'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AiSummaryToJson(AiSummary instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'week_start': instance.weekStart.toIso8601String(),
  'summary_text': instance.summaryText,
  'growth_observation': instance.growthObservation,
  'themes': instance.themes,
  'entry_count': instance.entryCount,
  'word_count_total': instance.wordCountTotal,
  'created_at': instance.createdAt.toIso8601String(),
};
