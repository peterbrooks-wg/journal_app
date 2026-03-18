# Reflect

An AI-powered journaling app built with Flutter. Reflect helps you build a consistent journaling habit by providing weekly AI-generated summaries of your entries, personalized writing prompts, and mood tracking — all with a focus on privacy.

## Features

- **Journal Editor** — Rich text editor with auto-save, mood picker, and search
- **AI Summaries** — Weekly AI-generated summaries of your journal entries powered by Gemini 2.0 Flash
- **Writing Prompts** — Personalized AI-generated prompts to inspire deeper reflection
- **Subscription Tiers** — Free tier (4 summaries/month) and Pro (unlimited)
- **Privacy Controls** — Biometric lock, data export, and full account deletion
- **Notifications** — Configurable daily reminders to journal

## Tech Stack

- **Framework:** Flutter / Dart
- **Backend:** Supabase (Postgres + Row Level Security + Edge Functions)
- **State Management:** Riverpod 3.x
- **Routing:** GoRouter
- **AI:** Gemini 2.0 Flash via Supabase Edge Functions
- **Auth:** Supabase Auth (Apple, Google, email)
- **Subscriptions:** RevenueCat

## Project Structure

```
lib/
  core/           # Theme, router, constants
  features/
    auth/         # Login, signup, onboarding screens
    journal/      # Home, editor, journal list
    summaries/    # AI summaries + writing prompts
    settings/     # Preferences, privacy, export
  shared/
    models/       # Data models (json_serializable)
    providers/    # Riverpod state providers

supabase/
  migrations/     # Postgres schema (6 tables with RLS)
  functions/      # Edge functions (summary generation, usage limits)
```

## Getting Started

### Prerequisites

- Flutter 3.x+
- A Supabase project (for backend features)
- Gemini API key (for AI features)

### Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/peterbrooks-wg/journal_app.git
   cd journal_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Supabase credentials in `lib/core/constants.dart`

4. Run the app:
   ```bash
   flutter run
   ```

## Status

The app is feature-complete with mock data. All UI screens, navigation, and state management are wired up. The next phase is connecting to a real Supabase backend.

## License

Proprietary. All rights reserved.
