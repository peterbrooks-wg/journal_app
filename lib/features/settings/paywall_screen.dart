import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/providers/subscription_provider.dart';

/// Paywall screen showing Pro upgrade options.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.yearly;
  bool _loading = false;

  Future<void> _subscribe() async {
    setState(() => _loading = true);
    await ref.read(subscriptionProvider.notifier).subscribe(_selectedPlan);
    if (mounted) {
      setState(() => _loading = false);
      context.pop();
    }
  }

  Future<void> _restore() async {
    await ref.read(subscriptionProvider.notifier).restore();
    if (mounted) {
      final isPro = ref.read(isProProvider);
      if (isPro) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No previous purchases found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Header
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.accent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Unlock Reflect Pro',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Deepen your journaling with AI insights',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Feature list
              const _FeatureRow(
                icon: Icons.auto_awesome_outlined,
                text: 'Weekly AI-powered summaries',
              ),
              const SizedBox(height: 12),
              const _FeatureRow(
                icon: Icons.lightbulb_outline,
                text: 'Personalized writing prompts',
              ),
              const SizedBox(height: 12),
              const _FeatureRow(
                icon: Icons.trending_up,
                text: 'Growth observations & themes',
              ),
              const SizedBox(height: 12),
              const _FeatureRow(
                icon: Icons.picture_as_pdf_outlined,
                text: 'PDF journal export',
              ),

              const SizedBox(height: 32),

              // Pricing cards
              Row(
                children: [
                  Expanded(
                    child: _PricingCard(
                      plan: SubscriptionPlan.monthly,
                      isSelected:
                          _selectedPlan == SubscriptionPlan.monthly,
                      onTap: () => setState(
                        () => _selectedPlan = SubscriptionPlan.monthly,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PricingCard(
                      plan: SubscriptionPlan.yearly,
                      isSelected:
                          _selectedPlan == SubscriptionPlan.yearly,
                      badge: 'Save 40%',
                      onTap: () => setState(
                        () => _selectedPlan = SubscriptionPlan.yearly,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Subscribe button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _subscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Subscribe — ${_selectedPlan.price}/${_selectedPlan.period}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Restore purchases
              TextButton(
                onPressed: _restore,
                child: Text(
                  'Restore purchases',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accent, size: 20),
        const SizedBox(width: 12),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _PricingCard({
    required this.plan,
    required this.isSelected,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              plan.price,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.accent : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'per ${plan.period}',
              style: textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
