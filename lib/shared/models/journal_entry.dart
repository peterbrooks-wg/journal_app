import 'package:json_annotation/json_annotation.dart';

part 'journal_entry.g.dart';

/// A single journal entry written by the user.
@JsonSerializable(fieldRename: FieldRename.snake)
class JournalEntry {
  final String id;
  final String userId;
  final String content;
  final int? wordCount;
  final String? moodTag;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.content,
    this.wordCount,
    this.moodTag,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);

  Map<String, dynamic> toJson() => _$JournalEntryToJson(this);
}
