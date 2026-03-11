import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/models/ai_summary.dart';
import '../../shared/providers/prompt_provider.dart';
import '../../shared/providers/summary_provider.dart';
import '../journal/widgets/prompt_card.dart';
import 'widgets/theme_chip.dart';

/// Full detail view for a weekly AI summary.
class SummaryDetailScreen extends ConsumerWidget {
  final String summaryId;

  const SummaryDetailScreen({super.key, required this.summaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(summaryProvider);
    final summary = summaries
        .cast<AiSummary?>()
        .firstWhere((s) => s?.id == summaryId, orElse: () => null);
    final prompts = ref.watch(promptsForSummaryProvider(summaryId));
    final textTheme = Theme.of(context).textTheme;

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Summary not found')),
      );
    }

    final dateRange =
        '${DateFormat.MMMd().format(summary.weekStart)} – '
        '${DateFormat.MMMd().format(summary.weekEnd)}';

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              '$dateRange · ${summary.entryCount} entries',
              style: textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text('Your Week', style: textTheme.titleLarge),
            const SizedBox(height: 16),

            // Theme chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: summary.themes
                  .map((t) => ThemeChip(label: t))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Summary text
            Text(
              summary.summaryText,
              style: textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),

            // Growth observation box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.08),
                border: const Border(
                  left: BorderSide(
                    color: AppTheme.accent,
                    width: 3,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: AppTheme.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'GROWTH',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary.growthObservation,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Personalized prompts
            if (prompts.isNotEmpty) ...[
              Text(
                'Prompts for this week',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...prompts.map(
                (prompt) => PromptCard(
                  promptText: prompt.promptText,
                  onTap: () => context.go('/journal/new'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
