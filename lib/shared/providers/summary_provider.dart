import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_summary.dart';

/// Manages the list of AI-generated weekly summaries.
class SummaryNotifier extends Notifier<List<AiSummary>> {
  @override
  List<AiSummary> build() => [];

  /// Bulk-replace summaries with pre-built data.
  void seedSummaries(List<AiSummary> summaries) {
    state = summaries;
  }

  /// Get a single summary by ID, or null.
  AiSummary? getSummary(String id) {
    for (final summary in state) {
      if (summary.id == id) return summary;
    }
    return null;
  }
}

/// Global summaries provider.
final summaryProvider =
    NotifierProvider<SummaryNotifier, List<AiSummary>>(
  SummaryNotifier.new,
);
