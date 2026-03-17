# Reflect — Next Steps Roadmap

> **Status:** All 8 build phases complete. App is feature-complete with mock data.
> Every provider uses in-memory or SharedPreferences — no real backend calls yet.

## Priority Order

### 1. Supabase Project Setup
- Create Supabase project at supabase.com
- Run `supabase/migrations/00001_initial_schema.sql` to create tables + RLS policies
- Copy project URL and anon key into `lib/core/constants.dart`
- Uncomment `await initSupabase()` in `lib/main.dart`
- Deploy edge functions: `supabase functions deploy generate-weekly-summary` and `check-usage-limit`
- Set edge function secrets: `GEMINI_API_KEY`

### 2. Real Authentication
- Replace mock `AuthNotifier` with Supabase Auth
- Wire up Apple Sign-In, Google Sign-In, email/password from `auth_screen.dart`
- Connect onboarding flow to create `user_profiles` row on first sign-up
- Update GoRouter redirect logic to use real auth state
- **Files:** `lib/shared/providers/auth_provider.dart`, `lib/features/auth/auth_screen.dart`

### 3. Real Journal CRUD
- Replace in-memory `JournalNotifier` with Supabase queries
- Insert/update/delete against `journal_entries` table
- Real-time subscription for live updates (optional)
- Remove demo data seeding from `main.dart`
- **Files:** `lib/shared/providers/journal_provider.dart`, `lib/main.dart`

### 4. Real Summaries + Prompts
- Replace in-memory `SummaryNotifier` and `PromptNotifier` with Supabase queries
- Fetch from `ai_summaries` and `ai_prompts` tables
- Wire up "generate summary" button or schedule via pg_cron → edge function
- **Files:** `lib/shared/providers/summary_provider.dart`, `lib/shared/providers/prompt_provider.dart`

### 5. Real Subscriptions (RevenueCat)
- Integrate `purchases_flutter` SDK
- Replace mock `SubscriptionNotifier` with RevenueCat purchase flows
- Sync subscription tier to `user_profiles.subscription_tier` in Supabase
- Wire paywall screen to real product IDs
- **Files:** `lib/shared/providers/subscription_provider.dart`, `lib/features/settings/paywall_screen.dart`

### 6. Push Notifications
- Configure Firebase project + `firebase_messaging`
- Store FCM token in `user_profiles.fcm_token`
- Implement daily reminder scheduling using `settingsProvider.reminderTime`
- **Files:** `lib/main.dart`, `lib/shared/providers/settings_provider.dart`

### 7. Biometric Lock
- Wire `local_auth` package to `settingsProvider.biometricLockEnabled`
- Add lock screen check on app resume
- **Files:** `lib/main.dart` or new `lib/features/auth/biometric_gate.dart`

### 8. Analytics
- Initialize PostHog in `main.dart`
- Track key events: entry created, summary viewed, subscription started
- **Files:** `lib/main.dart`

### 9. Export Journal (Real)
- Generate encrypted JSON of all entries
- Share via platform share sheet
- **Files:** `lib/features/settings/settings_screen.dart`

### 10. Test Coverage
- Currently: 1 smoke test
- Add widget tests for each screen
- Add unit tests for each provider
- Add integration tests for auth + journal flows

---

## Provider Migration Checklist

Each provider needs to be converted from mock → real Supabase:

- [ ] `authProvider` → Supabase Auth (signInWithOAuth, signInWithPassword, signOut)
- [ ] `journalProvider` → Supabase `journal_entries` (select, insert, update, delete)
- [ ] `summaryProvider` → Supabase `ai_summaries` (select, ordered by week_start)
- [ ] `promptProvider` → Supabase `ai_prompts` (select, filtered by summary_id)
- [ ] `subscriptionProvider` → RevenueCat + Supabase `user_profiles.subscription_tier`
- [ ] `settingsProvider` → Keep SharedPreferences, optionally sync to Supabase

## Files That Won't Change
- All models (`lib/shared/models/`) — already match Supabase schema
- All UI screens — consume providers, don't care about data source
- Edge functions (`supabase/functions/`) — already production-ready
- Router (`lib/core/router.dart`) — already handles auth redirects
- Theme (`lib/core/theme.dart`) — complete

## Credentials Needed
| Service | Where to Set | Purpose |
|---|---|---|
| Supabase URL + Anon Key | `lib/core/constants.dart` | Flutter ↔ Supabase |
| Gemini API Key | Edge function env var | AI summaries |
| RevenueCat API Key | `purchases_flutter` init | Subscriptions |
| Firebase config | `google-services.json` / `GoogleService-Info.plist` | Push notifications |
| PostHog API Key | `posthog_flutter` init | Analytics |
