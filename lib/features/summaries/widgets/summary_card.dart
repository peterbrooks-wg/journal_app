import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/ai_summary.dart';
import 'theme_chip.dart';

/// A card displaying a weekly summary preview.
class SummaryCard extends StatelessWidget {
  final AiSummary summary;
  final VoidCallback? onTap;

  const SummaryCard({super.key, required this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateRange =
        '${DateFormat.MMMd().format(summary.weekStart)} – '
        '${DateFormat.MMMd().format(summary.weekEnd)}';
    final stats =
        '${summary.entryCount} entries · '
        '${summary.wordCountTotal} words';
    final preview = summary.summaryText.length > 120
        ? '${summary.summaryText.substring(0, 120)}...'
        : summary.summaryText;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateRange, style: textTheme.labelSmall),
                  Text(stats, style: textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                preview,
                style: textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: summary.themes
                    .map((t) => ThemeChip(label: t))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
