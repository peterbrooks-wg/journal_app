import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/providers/journal_provider.dart';
import 'widgets/entry_card.dart';
import 'widgets/prompt_card.dart';

/// Home screen with greeting, prompts, and recent entries.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _genericPrompts = [
    'What are you grateful for today?',
    'What challenge taught you something this week?',
    'Describe a moment that made you smile recently.',
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentEntries = ref.watch(recentEntriesProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  _greeting(),
                  style: textTheme.displayLarge,
                ),
              ),
            ),
            // Prompts section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Prompts for you',
                  style: textTheme.titleMedium,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _genericPrompts
                      .map(
                        (prompt) => PromptCard(
                          promptText: prompt,
                          onTap: () => context.go('/journal/new'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            // Recent entries section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Recent entries',
                      style: textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/journal'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            if (recentEntries.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.edit_note_rounded,
                            size: 40,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start your first entry',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap the button below to begin writing',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = recentEntries[index];
                    return EntryCard(
                      entry: entry,
                      onTap: () => context.go('/journal/${entry.id}'),
                    );
                  },
                  childCount: recentEntries.length,
                ),
              ),
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/journal/new'),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
