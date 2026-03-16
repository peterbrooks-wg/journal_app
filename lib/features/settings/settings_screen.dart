import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/subscription_provider.dart';

/// Settings screen with profile, subscription badge, and sign out.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                // Avatar
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
          const SwitchListTile(
            title: Text('Notifications'),
            value: true,
            onChanged: null,
            activeThumbColor: AppTheme.accent,
          ),
          ListTile(
            title: const Text('Daily reminder'),
            trailing: Text(
              '8:00 AM',
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          const Divider(),

          // Privacy
          _SectionHeader(text: 'PRIVACY', textTheme: textTheme),
          const ListTile(
            title: Text('Export my data'),
            trailing: Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
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
