# Phase 7: Subscriptions — Design

## Overview

Mock subscription system with full paywall UI. SubscriptionNotifier manages free/pro state via SharedPreferences. Feature gates check tier before allowing Pro features. Real RevenueCat wiring comes later.

## Subscription Provider

- `SubscriptionNotifier` (Riverpod Notifier) managing `SubscriptionTier` enum (free/pro)
- Persisted to SharedPreferences
- Methods: `subscribe(plan)`, `restore()`, `cancel()` — all mock (immediate success)
- `isProProvider` convenience provider for gates

## Paywall Screen

- Route: `/paywall`
- Feature comparison section (free vs pro checklist)
- Two pricing cards: monthly ($6.99) and yearly ($49.99, ~40% off badge)
- Mock "Subscribe" button → sets tier to pro, navigates back
- "Restore Purchases" text button at bottom
- Clean, calm design matching app brand

## Feature Gates

- Summaries list: free users see a paywall prompt instead of summaries
- Home screen: already falls back to generic prompts for free users (no change needed)
- Settings: dynamic badge shows current tier + upgrade/manage button

## Files

```
lib/shared/providers/
  subscription_provider.dart       — new
lib/features/settings/
  paywall_screen.dart              — new
  settings_screen.dart             — modify (dynamic badge)
lib/features/summaries/
  summaries_list_screen.dart       — modify (pro gate)
lib/core/
  router.dart                      — add /paywall route
```

## Pricing

- Free: Unlimited journaling, 3 generic prompts/month
- Pro Monthly: $6.99/month — Weekly AI summaries, personalized prompts, theme history
- Pro Yearly: $49.99/year (~40% discount)
