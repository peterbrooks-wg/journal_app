import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// The five mood options available for journal entries.
enum Mood {
  good('Good', '😊'),
  hard('Hard', '😔'),
  mixed('Mixed', '😐'),
  reflective('Reflective', '🤔'),
  grateful('Grateful', '🙏');

  final String label;
  final String emoji;

  const Mood(this.label, this.emoji);

  /// The value stored in the database.
  String get tag => name;

  /// Find a Mood by its tag string, or null.
  static Mood? fromTag(String? tag) {
    if (tag == null) return null;
    for (final mood in values) {
      if (mood.tag == tag) return mood;
    }
    return null;
  }
}

/// Shows a bottom sheet for selecting a mood.
///
/// Returns the selected [Mood], or null if dismissed.
Future<Mood?> showMoodPicker(
  BuildContext context, {
  Mood? currentMood,
}) {
  return showModalBottomSheet<Mood>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _MoodPickerSheet(currentMood: currentMood),
  );
}

class _MoodPickerSheet extends StatelessWidget {
  final Mood? currentMood;

  const _MoodPickerSheet({this.currentMood});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'How are you feeling?',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: Mood.values.map((mood) {
              final isSelected = mood == currentMood;
              return GestureDetector(
                onTap: () => Navigator.pop(context, mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accent.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppTheme.accent, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mood.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood.label,
                        style: textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? AppTheme.accent
                              : AppTheme.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
