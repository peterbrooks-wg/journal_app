import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/journal_entry.dart';

/// Manages the list of journal entries.
///
/// Uses an in-memory list as a mock repository.
/// Replace with Supabase calls in a later phase.
class JournalNotifier extends Notifier<List<JournalEntry>> {
  @override
  List<JournalEntry> build() => [];

  /// Add a new entry and return its ID.
  String addEntry({required String content, String? moodTag}) {
    final now = DateTime.now();
    final entry = JournalEntry(
      id: now.microsecondsSinceEpoch.toString(),
      userId: 'mock-user',
      content: content,
      wordCount: _countWords(content),
      moodTag: moodTag,
      createdAt: now,
      updatedAt: now,
    );
    state = [entry, ...state];
    return entry.id;
  }

  /// Update an existing entry's content and/or mood.
  void updateEntry({required String id, String? content, String? moodTag}) {
    state = [
      for (final entry in state)
        if (entry.id == id)
          JournalEntry(
            id: entry.id,
            userId: entry.userId,
            content: content ?? entry.content,
            wordCount: _countWords(content ?? entry.content),
            moodTag: moodTag ?? entry.moodTag,
            createdAt: entry.createdAt,
            updatedAt: DateTime.now(),
          )
        else
          entry,
    ];
  }

  /// Delete an entry by ID.
  void deleteEntry(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  /// Get a single entry by ID, or null.
  JournalEntry? getEntry(String id) {
    for (final entry in state) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  static int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}

/// Global journal entries provider.
final journalProvider = NotifierProvider<JournalNotifier, List<JournalEntry>>(
  JournalNotifier.new,
);

/// Entries from the last 7 days, for the home screen.
final recentEntriesProvider = Provider<List<JournalEntry>>((ref) {
  final entries = ref.watch(journalProvider);
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  return entries.where((e) => e.createdAt.isAfter(cutoff)).toList();
});

/// Filtered entries for search.
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredEntriesProvider = Provider<List<JournalEntry>>((ref) {
  final entries = ref.watch(journalProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return entries;
  return entries.where((e) => e.content.toLowerCase().contains(query)).toList();
});
