import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's subscription tier.
enum SubscriptionTier {
  free,
  pro;

  /// Display label for the tier.
  String get label => this == pro ? 'Pro' : 'Free';
}

/// Plan options for the paywall.
enum SubscriptionPlan {
  monthly(price: '\$6.99', period: 'month'),
  yearly(price: '\$49.99', period: 'year');

  final String price;
  final String period;

  const SubscriptionPlan({required this.price, required this.period});
}

/// Manages subscription state.
///
/// Mock implementation using SharedPreferences.
/// Replace with RevenueCat SDK calls later.
class SubscriptionNotifier extends Notifier<SubscriptionTier> {
  static const _key = 'subscription_tier';

  @override
  SubscriptionTier build() {
    _loadFromPrefs();
    return SubscriptionTier.free;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == 'pro') {
      state = SubscriptionTier.pro;
    }
  }

  /// Mock subscribe — immediately grants Pro.
  Future<void> subscribe(SubscriptionPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'pro');
    state = SubscriptionTier.pro;
  }

  /// Mock restore purchases.
  Future<void> restore() async {
    await _loadFromPrefs();
  }

  /// Mock cancel — reverts to free.
  Future<void> cancel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'free');
    state = SubscriptionTier.free;
  }
}

/// Global subscription tier provider.
final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionTier>(
  SubscriptionNotifier.new,
);

/// Convenience: true if user has Pro.
final isProProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider) == SubscriptionTier.pro;
});
