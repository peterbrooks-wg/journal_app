import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_prompt.dart';
import 'summary_provider.dart';

/// Manages the list of AI-generated prompts.
class PromptNotifier extends Notifier<List<AiPrompt>> {
  @override
  List<AiPrompt> build() => [];

  /// Bulk-replace prompts with pre-built data.
  void seedPrompts(List<AiPrompt> prompts) {
    state = prompts;
  }
}

/// Global prompts provider.
final promptProvider =
    NotifierProvider<PromptNotifier, List<AiPrompt>>(
  PromptNotifier.new,
);

/// Prompts for a specific summary.
final promptsForSummaryProvider =
    Provider.family<List<AiPrompt>, String>((ref, summaryId) {
  final prompts = ref.watch(promptProvider);
  return prompts.where((p) => p.summaryId == summaryId).toList();
});

/// Prompts from the most recent summary (for the home screen).
final latestPromptsProvider = Provider<List<AiPrompt>>((ref) {
  final summaries = ref.watch(summaryProvider);
  final prompts = ref.watch(promptProvider);
  if (summaries.isEmpty) return [];

  // Find the newest summary by weekStart.
  final sorted = [...summaries]
    ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
  final latestId = sorted.first.id;

  return prompts.where((p) => p.summaryId == latestId).toList();
});
