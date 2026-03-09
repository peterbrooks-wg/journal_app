# Phase 4: Journal Feature — Design

## Overview

Build the full journal experience: home screen with greeting and prompts, entry editor with auto-save and mood picker, entry list with search.

## Screens

### Home Screen
- Greeting with time of day ("Good morning/afternoon/evening")
- "Prompts for you" section (3 generic placeholder cards — personalized prompts come Phase 6)
- Recent entries (last 7 days) as cards
- FAB for new entry

### Entry Editor
- Full-screen TextField with minimal chrome
- Date header at top
- Word count in bottom bar
- Mood picker (5 emoji options: good, hard, mixed, reflective, grateful)
- Auto-save with 1500ms debounce
- Save on AppLifecycleState.paused

### Entry List
- Full history, reverse chronological
- Search bar at top (client-side filter by content substring)
- Tap entry to edit

## Data Layer

- `JournalRepository` — mock in-memory CRUD (real Supabase later)
- `JournalNotifier` (Riverpod) — manages entries list state
- Auto-save via Timer debounce in editor

## Files

```
lib/features/journal/
  home_screen.dart
  journal_entry_screen.dart
  journal_list_screen.dart
  widgets/
    mood_picker.dart
    entry_card.dart
    prompt_card.dart
lib/shared/providers/
  journal_provider.dart
```
