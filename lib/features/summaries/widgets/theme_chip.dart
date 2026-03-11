import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// A small pill displaying a summary theme label.
class ThemeChip extends StatelessWidget {
  final String label;

  const ThemeChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.accent,
        ),
      ),
    );
  }
}
