import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/providers/summary_provider.dart';
import 'widgets/summary_card.dart';

/// Displays a scrollable list of weekly AI summaries.
class SummariesListScreen extends ConsumerWidget {
  const SummariesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(summaryProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: summaries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No summaries yet',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your first summary will appear after\na week of journaling',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final summary = summaries[index];
                      return SummaryCard(
                        summary: summary,
                        onTap: () =>
                            context.go('/summaries/${summary.id}'),
                      );
                    },
                    childCount: summaries.length,
                  ),
                ),
                // Pro badge at bottom
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.accent,
                              Color(0xFF5A7F87),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Pro — Weekly AI Summaries',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
