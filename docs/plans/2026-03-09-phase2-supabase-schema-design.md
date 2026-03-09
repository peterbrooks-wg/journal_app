# Phase 2: Supabase Schema — Design

## Overview

Create the Supabase database schema with 6 tables, RLS policies, an auto-profile trigger, and corresponding Dart model classes.

## Tables

| Table | Purpose | Key columns |
|-------|---------|-------------|
| `user_profiles` | Extends auth.users with app data | subscription_tier, onboarding_completed, timezone, fcm_token |
| `journal_entries` | User journal content | content, word_count (generated), mood_tag (check constraint) |
| `ai_summaries` | Weekly AI-generated summaries | week_start, summary_text, themes[], entry_count |
| `ai_prompts` | AI-generated writing prompts | prompt_text, source_themes[], used, used_at |
| `running_summaries` | Progressive summarization context | summary_text, last_entry_id |
| `usage_tracking` | Monthly AI usage limits | month, ai_prompt_requests, summary_count |

## RLS

- Enable RLS on all 6 tables
- Each table: SELECT, INSERT, UPDATE, DELETE where `auth.uid() = user_id`
- `user_profiles` uses `id` (not `user_id`)

## Trigger

- `on_auth_user_created`: After INSERT on `auth.users`, auto-insert `user_profiles` row

## Dart Models

- Data classes in `lib/shared/models/` for each table
- `fromJson`/`toJson` via `json_serializable`
- `@JsonSerializable(fieldRename: FieldRename.snake)` for snake_case DB columns

## File Output

```
supabase/migrations/00001_initial_schema.sql
lib/shared/models/
  user_profile.dart
  journal_entry.dart
  ai_summary.dart
  ai_prompt.dart
  running_summary.dart
  usage_tracking.dart
```
