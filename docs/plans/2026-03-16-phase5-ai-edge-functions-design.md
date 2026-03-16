# Phase 5: AI Edge Functions — Design

## Overview

Two Supabase Edge Functions: `generate-weekly-summary` (core AI pipeline) and `check-usage-limit` (rate limiting guard). Uses Gemini 2.0 Flash with structured JSON output via direct REST calls. Progressive summarization keeps token costs flat.

## Edge Functions

### generate-weekly-summary

Triggered by pg_cron (Sunday 8am per user timezone) or invoked on-demand.

**Pipeline:**
1. Receive `user_id` from request body
2. Check usage limit (inline, not separate HTTP call)
3. Fetch `running_summaries` row for user
4. Fetch `journal_entries` created after `last_entry_id`
5. If no new entries, exit early with `{ skipped: true }`
6. Compress entries (strip formatting, cap 500 words each)
7. Build prompt: system instruction + running summary + compressed entries
8. Call Gemini 2.0 Flash with JSON structured output schema
9. Parse response: `{ summary, themes, growth_observation, prompts[3] }`
10. Insert into `ai_summaries`
11. Insert 3 rows into `ai_prompts`
12. Update `running_summaries` with new summary text + last_entry_id
13. Increment `usage_tracking`

### check-usage-limit

Lightweight guard called before AI requests.

- Validates user JWT
- Checks `usage_tracking` for current month
- Returns `{ allowed, remaining, limit }`
- Free tier: 4 summaries/month; Pro tier: unlimited

## AI Provider

- **Model:** Gemini 2.0 Flash (`gemini-2.0-flash`)
- **Method:** Direct REST via `fetch()` — no SDK dependency
- **Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent`
- **Structured output:** `responseMimeType: "application/json"` + `responseJsonSchema`

## Prompt Design

**System instruction:**
```
You are a compassionate journaling companion. Analyze the user's journal entries
and provide a thoughtful weekly summary. Be warm but not saccharine. Notice patterns
and growth. Never judge or diagnose.
```

**Response JSON schema:**
```json
{
  "type": "object",
  "properties": {
    "summary": { "type": "string", "description": "2-3 paragraph weekly summary" },
    "themes": {
      "type": "array",
      "items": { "type": "string" },
      "minItems": 1, "maxItems": 5
    },
    "growth_observation": { "type": "string", "description": "One sentence noting growth or change" },
    "prompts": {
      "type": "array",
      "items": { "type": "string" },
      "minItems": 3, "maxItems": 3,
      "description": "3 personalized writing prompts for next week"
    }
  },
  "required": ["summary", "themes", "growth_observation", "prompts"]
}
```

## Progressive Summarization

After each generation, the new `summary` replaces the `running_summaries.summary_text`. This means token usage stays constant regardless of how long the user has been journaling — the model only ever sees the running summary + this week's entries.

## Files

```
supabase/functions/
  _shared/
    supabase-client.ts    — creates authenticated Supabase client
    gemini.ts             — Gemini API call helper
    cors.ts               — CORS headers helper
  generate-weekly-summary/
    index.ts              — main handler
  check-usage-limit/
    index.ts              — main handler
```

## Environment Secrets

- `GEMINI_API_KEY` — Google AI API key
- `SUPABASE_URL` — auto-provided by runtime
- `SUPABASE_SERVICE_ROLE_KEY` — auto-provided by runtime

## Error Handling

- Gemini non-200 → 502 with error message
- No new entries → 200 with `{ skipped: true, reason: "no_new_entries" }`
- Usage limit exceeded → 429 with `{ allowed: false }`
- DB write failure → 500 with error message

## Out of Scope

- pg_cron scheduling (dashboard config, not code)
- FCM push notifications (deferred to later phase)
- Flutter-side providers or UI (Phase 6)
- Real Supabase auth wiring (still mock in Flutter)
