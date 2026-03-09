# Phase 1: Project Scaffold — Design

## Overview

Initialize the Reflect Flutter project in the current `journal_app` directory with full folder structure, routing, theming, Supabase client, and Riverpod state management.

## Architecture

**Project root**: `/Users/jbdgw/Developer/JB/apps/journal_app/`
Initialize with `flutter create . --project-name reflect`.

### Folder Structure

```
lib/
  core/
    theme.dart          — ThemeData (light/dark), colors, typography
    constants.dart      — App-wide constants
    router.dart         — GoRouter configuration
    supabase.dart       — Supabase client initialization
  features/
    auth/               — placeholder
    journal/            — placeholder
    summaries/          — placeholder
    prompts/            — placeholder
    settings/           — placeholder
  shared/
    models/             — Dart data classes
    providers/          — Riverpod providers
    widgets/            — Reusable widgets
  main.dart             — Entry point
```

## Key Decisions

- **State management**: Riverpod (`flutter_riverpod` + `riverpod`)
- **Routing**: `go_router` with routes: `/`, `/onboarding`, `/auth`, `/journal`, `/journal/new`, `/journal/:id`, `/summaries`, `/settings`
- **Theme**: Off-white `#FAFAF8`, navy text `#1A1A2E`, accent `#7B9EA6`. System font. Follows system dark mode.
- **Supabase**: Initialized in `main.dart` before `runApp()`, config from constants

## Dependencies

`supabase_flutter`, `flutter_riverpod`, `riverpod`, `go_router`, `purchases_flutter`, `firebase_messaging`, `posthog_flutter`, `local_auth`, `shared_preferences`, `intl`

## Deliverables

- Running Flutter app with folder structure
- GoRouter navigation between placeholder screens
- Supabase client configured
- Riverpod ProviderScope wrapping app
- Theme applied globally
- All dependencies installed

## Out of Scope

- UI beyond placeholder screens
- Supabase schema (Phase 2)
- Auth (Phase 3)
- Journal feature (Phase 4)
