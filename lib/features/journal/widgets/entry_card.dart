import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/journal_entry.dart';
import 'mood_picker.dart';

/// A card displaying a journal entry preview.
class EntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback? onTap;

  const EntryCard({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateStr = DateFormat.MMMEd().format(entry.createdAt);
    final mood = Mood.fromTag(entry.moodTag);
    final preview = _truncate(entry.content, 100);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    dateStr,
                    style: textTheme.labelSmall,
                  ),
                  if (mood != null) ...[
                    const SizedBox(width: 8),
                    Text(mood.emoji, style: const TextStyle(fontSize: 14)),
                  ],
                  const Spacer(),
                  if (entry.wordCount != null)
                    Text(
                      '${entry.wordCount} words',
                      style: textTheme.labelSmall,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                preview,
                style: textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _truncate(String text, int maxChars) {
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars)}...';
  }
}
