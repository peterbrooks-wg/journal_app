import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/journal_provider.dart';
import '../../shared/providers/prompt_provider.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/providers/subscription_provider.dart';
import '../../shared/providers/summary_provider.dart';

/// Settings screen with profile, subscription, preferences, and privacy.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'J',
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jordan', style: textTheme.titleMedium),
                    Text(
                      'jordan@example.com',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Subscription badge
          _SubscriptionBadge(textTheme: textTheme),

          const SizedBox(height: 24),
          const Divider(),

          // Preferences
          _SectionHeader(text: 'PREFERENCES', textTheme: textTheme),
          SwitchListTile(
            title: const Text('Notifications'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .setNotificationsEnabled(value);
            },
            activeThumbColor: AppTheme.accent,
          ),
          ListTile(
            title: const Text('Daily reminder'),
            trailing: Text(
              settings.reminderTime.format(context),
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            onTap: () => _pickReminderTime(context, ref, settings),
          ),

          const Divider(),

          // Security
          _SectionHeader(text: 'SECURITY', textTheme: textTheme),
          SwitchListTile(
            title: const Text('Biometric lock'),
            subtitle: const Text('Require Face ID or fingerprint'),
            value: settings.biometricLockEnabled,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .setBiometricLockEnabled(value);
            },
            activeThumbColor: AppTheme.accent,
          ),

          const Divider(),

          // Privacy
          _SectionHeader(text: 'PRIVACY', textTheme: textTheme),
          ListTile(
            title: const Text('Export my data'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
            onTap: () => _showExportDialog(context),
          ),
          ListTile(
            title: Text(
              'Delete all data',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.red,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
            onTap: () => _showDeleteDialog(context, ref),
          ),

          const Divider(),
          const SizedBox(height: 8),

          // Sign out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
              },
              child: const Text('Sign out'),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime,
    );
    if (picked != null) {
      ref.read(settingsProvider.notifier).setReminderTime(picked);
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Journal'),
        content: const Text(
          'Your journal entries will be exported as an '
          'encrypted JSON file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Journal exported successfully'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(ref: ref),
    );
  }
}

class _DeleteConfirmationDialog extends StatefulWidget {
  final WidgetRef ref;

  const _DeleteConfirmationDialog({required this.ref});

  @override
  State<_DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState
    extends State<_DeleteConfirmationDialog> {
  final _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _canDelete = _controller.text == 'DELETE');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete All Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will permanently delete all your journal entries, '
            'summaries, and prompts. This action cannot be undone.',
          ),
          const SizedBox(height: 16),
          const Text('Type DELETE to confirm:'),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'DELETE',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canDelete
              ? () {
                  // Clear all mock data
                  widget.ref
                      .read(journalProvider.notifier)
                      .seedEntries([]);
                  widget.ref
                      .read(summaryProvider.notifier)
                      .seedSummaries([]);
                  widget.ref
                      .read(promptProvider.notifier)
                      .seedPrompts([]);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data deleted'),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete Everything'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  final TextTheme textTheme;

  const _SectionHeader({required this.text, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SubscriptionBadge extends ConsumerWidget {
  final TextTheme textTheme;

  const _SubscriptionBadge({required this.textTheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: isPro ? null : () => context.push('/paywall'),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isPro ? AppTheme.accent : AppTheme.textSecondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPro ? 'Pro' : 'Free',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isPro
                    ? 'Weekly AI summaries \u00b7 Personalized prompts'
                    : 'Upgrade for AI summaries & prompts',
                style: textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            if (!isPro)
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
