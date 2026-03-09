import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// A card displaying a journal prompt.
///
/// Shows generic placeholder prompts for now.
/// Personalized AI prompts come in Phase 6.
class PromptCard extends StatelessWidget {
  final String promptText;
  final VoidCallback? onTap;

  const PromptCard({
    super.key,
    required this.promptText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.accent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  promptText,
                  style: textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
