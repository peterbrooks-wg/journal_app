# Phase 5: AI Edge Functions Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build two Supabase Edge Functions — `generate-weekly-summary` (Gemini 2.0 Flash AI pipeline) and `check-usage-limit` (rate limiting guard).

**Architecture:** Edge functions written in TypeScript/Deno. `generate-weekly-summary` fetches journal entries, compresses them, calls Gemini 2.0 Flash REST API with structured JSON output, and stores results in the database. `check-usage-limit` reads usage_tracking and returns whether the user can request more AI features. Shared utilities in `_shared/` directory.

**Tech Stack:** Supabase Edge Functions (Deno runtime), Gemini 2.0 Flash REST API, supabase-js client

---

### Task 1: Create Shared CORS Helper

**Files:**
- Create: `supabase/functions/_shared/cors.ts`

**Step 1: Create cors.ts**

```typescript
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};
```

**Step 2: Commit**

```bash
git add supabase/functions/_shared/cors.ts
git commit -m "feat: add shared CORS headers for edge functions"
```

---

### Task 2: Create Shared Supabase Client Helper

**Files:**
- Create: `supabase/functions/_shared/supabase-client.ts`

**Step 1: Create supabase-client.ts**

This creates a Supabase client using the **service role key** (bypasses RLS). Edge functions called by pg_cron don't have a user JWT, so they need the service role.

```typescript
import { createClient } from 'npm:@supabase/supabase-js@2';

/**
 * Creates a Supabase client with the service role key.
 *
 * Use this for server-side operations (pg_cron, background jobs)
 * where there is no user JWT. Bypasses Row Level Security.
 */
export function createServiceClient() {
  return createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  );
}

/**
 * Creates a Supabase client using the user's JWT from the
 * Authorization header. Respects Row Level Security.
 */
export function createUserClient(req: Request) {
  return createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    {
      global: {
        headers: {
          Authorization: req.headers.get('Authorization')!,
        },
      },
    },
  );
}
```

**Step 2: Commit**

```bash
git add supabase/functions/_shared/supabase-client.ts
git commit -m "feat: add shared Supabase client helpers for edge functions"
```

---

### Task 3: Create Shared Gemini API Helper

**Files:**
- Create: `supabase/functions/_shared/gemini.ts`

**Step 1: Create gemini.ts**

Direct REST call to Gemini 2.0 Flash with structured JSON output. No SDK dependency.

```typescript
const GEMINI_MODEL = 'gemini-2.0-flash';
const GEMINI_BASE_URL =
  'https://generativelanguage.googleapis.com/v1beta/models';

/** The structured response we expect from Gemini. */
export interface WeeklySummaryResponse {
  summary: string;
  themes: string[];
  growth_observation: string;
  prompts: string[];
}

/** JSON schema for Gemini structured output. */
const weeklySummarySchema = {
  type: 'object',
  properties: {
    summary: {
      type: 'string',
      description: '2-3 paragraph weekly summary of journal entries',
    },
    themes: {
      type: 'array',
      items: { type: 'string' },
      minItems: 1,
      maxItems: 5,
      description: 'Key themes from the entries',
    },
    growth_observation: {
      type: 'string',
      description:
        'One sentence noting personal growth or positive change',
    },
    prompts: {
      type: 'array',
      items: { type: 'string' },
      minItems: 3,
      maxItems: 3,
      description: '3 personalized writing prompts for next week',
    },
  },
  required: ['summary', 'themes', 'growth_observation', 'prompts'],
};

const SYSTEM_INSTRUCTION = `You are a compassionate journaling companion. \
Analyze the user's journal entries and provide a thoughtful weekly summary. \
Be warm but not saccharine. Notice patterns and growth. Never judge or diagnose.`;

/**
 * Calls Gemini 2.0 Flash to generate a weekly summary.
 *
 * Uses structured JSON output so the response is guaranteed to
 * match our schema.
 */
export async function generateWeeklySummary(
  runningSummary: string,
  entries: { date: string; mood: string | null; content: string }[],
): Promise<WeeklySummaryResponse> {
  const apiKey = Deno.env.get('GEMINI_API_KEY');
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY is not set');
  }

  const entriesText = entries
    .map(
      (e, i) =>
        `Entry ${i + 1} (${e.date}${e.mood ? ` — mood: ${e.mood}` : ''}):\n${e.content}`,
    )
    .join('\n\n');

  const userMessage = runningSummary
    ? `Here is the user's running context from previous weeks:\n${runningSummary}\n\nHere are their new journal entries this week:\n\n${entriesText}\n\nPlease provide a weekly summary with themes, a growth observation, and 3 personalized prompts.`
    : `Here are the user's journal entries this week:\n\n${entriesText}\n\nPlease provide a weekly summary with themes, a growth observation, and 3 personalized prompts.`;

  const url = `${GEMINI_BASE_URL}/${GEMINI_MODEL}:generateContent`;

  const response = await fetch(`${url}?key=${apiKey}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      system_instruction: {
        parts: [{ text: SYSTEM_INSTRUCTION }],
      },
      contents: [
        {
          role: 'user',
          parts: [{ text: userMessage }],
        },
      ],
      generationConfig: {
        responseMimeType: 'application/json',
        responseJsonSchema: weeklySummarySchema,
        maxOutputTokens: 1500,
        temperature: 0.7,
      },
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(
      `Gemini API error (${response.status}): ${errorBody}`,
    );
  }

  const data = await response.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;

  if (!text) {
    throw new Error('Gemini returned empty response');
  }

  return JSON.parse(text) as WeeklySummaryResponse;
}
```

**Step 2: Commit**

```bash
git add supabase/functions/_shared/gemini.ts
git commit -m "feat: add Gemini 2.0 Flash API helper with structured output"
```

---

### Task 4: Create generate-weekly-summary Edge Function

**Files:**
- Create: `supabase/functions/generate-weekly-summary/index.ts`

**Step 1: Create index.ts**

This is the main AI pipeline. Called by pg_cron with a `user_id` in the request body.

```typescript
import { corsHeaders } from '../_shared/cors.ts';
import { createServiceClient } from '../_shared/supabase-client.ts';
import { generateWeeklySummary } from '../_shared/gemini.ts';

const FREE_TIER_MONTHLY_LIMIT = 4;

/** Compress an entry to at most 500 words. */
function compressEntry(content: string, maxWords = 500): string {
  const words = content.trim().split(/\s+/);
  if (words.length <= maxWords) return content.trim();
  return words.slice(0, maxWords).join(' ') + '...';
}

/** Get the first day of the current month as a date string. */
function currentMonth(): string {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`;
}

/** Get the Monday of the current week as a date string. */
function currentWeekStart(): string {
  const now = new Date();
  const day = now.getDay();
  const diff = now.getDate() - day + (day === 0 ? -6 : 1);
  const monday = new Date(now.setDate(diff));
  return monday.toISOString().split('T')[0];
}

/** Format a date for display in the prompt. */
function formatDate(dateStr: string): string {
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
  });
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { user_id } = await req.json();
    if (!user_id) {
      return new Response(
        JSON.stringify({ error: 'user_id is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const supabase = createServiceClient();

    // 1. Check usage limit
    const month = currentMonth();
    const { data: usage } = await supabase
      .from('usage_tracking')
      .select('summary_count')
      .eq('user_id', user_id)
      .eq('month', month)
      .single();

    const { data: profile } = await supabase
      .from('user_profiles')
      .select('subscription_tier')
      .eq('id', user_id)
      .single();

    const tier = profile?.subscription_tier ?? 'free';
    const currentCount = usage?.summary_count ?? 0;

    if (tier === 'free' && currentCount >= FREE_TIER_MONTHLY_LIMIT) {
      return new Response(
        JSON.stringify({ allowed: false, reason: 'usage_limit_exceeded' }),
        { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // 2. Fetch running summary
    const { data: runningSummary } = await supabase
      .from('running_summaries')
      .select('summary_text, last_entry_id')
      .eq('user_id', user_id)
      .single();

    // 3. Fetch new entries since last summary
    let entriesQuery = supabase
      .from('journal_entries')
      .select('id, content, mood_tag, created_at, word_count')
      .eq('user_id', user_id)
      .order('created_at', { ascending: true });

    if (runningSummary?.last_entry_id) {
      // Get the created_at of the last processed entry
      const { data: lastEntry } = await supabase
        .from('journal_entries')
        .select('created_at')
        .eq('id', runningSummary.last_entry_id)
        .single();

      if (lastEntry) {
        entriesQuery = entriesQuery.gt(
          'created_at',
          lastEntry.created_at,
        );
      }
    }

    const { data: entries, error: entriesError } = await entriesQuery;

    if (entriesError) {
      throw new Error(`Failed to fetch entries: ${entriesError.message}`);
    }

    if (!entries || entries.length === 0) {
      return new Response(
        JSON.stringify({ skipped: true, reason: 'no_new_entries' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // 4. Compress entries for the prompt
    const compressedEntries = entries.map((e) => ({
      date: formatDate(e.created_at),
      mood: e.mood_tag,
      content: compressEntry(e.content),
    }));

    // 5. Call Gemini
    const aiResult = await generateWeeklySummary(
      runningSummary?.summary_text ?? '',
      compressedEntries,
    );

    // 6. Calculate totals
    const entryCount = entries.length;
    const wordCountTotal = entries.reduce(
      (sum, e) => sum + (e.word_count ?? 0),
      0,
    );
    const lastEntryId = entries[entries.length - 1].id;
    const weekStart = currentWeekStart();

    // 7. Insert ai_summaries row
    const { error: summaryError } = await supabase
      .from('ai_summaries')
      .insert({
        user_id,
        week_start: weekStart,
        summary_text: aiResult.summary,
        themes: aiResult.themes,
        entry_count: entryCount,
        word_count_total: wordCountTotal,
      });

    if (summaryError) {
      throw new Error(
        `Failed to insert summary: ${summaryError.message}`,
      );
    }

    // 8. Insert 3 ai_prompts rows
    const promptRows = aiResult.prompts.map((promptText) => ({
      user_id,
      prompt_text: promptText,
      source_themes: aiResult.themes,
    }));

    const { error: promptsError } = await supabase
      .from('ai_prompts')
      .insert(promptRows);

    if (promptsError) {
      throw new Error(
        `Failed to insert prompts: ${promptsError.message}`,
      );
    }

    // 9. Upsert running_summaries
    const { error: runningError } = await supabase
      .from('running_summaries')
      .upsert(
        {
          user_id,
          summary_text: aiResult.summary,
          last_entry_id: lastEntryId,
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'user_id' },
      );

    if (runningError) {
      throw new Error(
        `Failed to update running summary: ${runningError.message}`,
      );
    }

    // 10. Upsert usage_tracking
    const { error: usageError } = await supabase
      .from('usage_tracking')
      .upsert(
        {
          user_id,
          month,
          summary_count: currentCount + 1,
          ai_prompt_requests: 0,
        },
        { onConflict: 'user_id,month' },
      );

    if (usageError) {
      throw new Error(
        `Failed to update usage: ${usageError.message}`,
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        summary: aiResult.summary,
        themes: aiResult.themes,
        growth_observation: aiResult.growth_observation,
        prompts_created: aiResult.prompts.length,
        entries_processed: entryCount,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('generate-weekly-summary error:', err);
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
```

**Step 2: Commit**

```bash
git add supabase/functions/generate-weekly-summary/index.ts
git commit -m "feat: add generate-weekly-summary edge function"
```

---

### Task 5: Create check-usage-limit Edge Function

**Files:**
- Create: `supabase/functions/check-usage-limit/index.ts`

**Step 1: Create index.ts**

Lightweight endpoint. Called from the Flutter app before requesting AI features. Uses the user's JWT (not service role).

```typescript
import { corsHeaders } from '../_shared/cors.ts';
import { createUserClient } from '../_shared/supabase-client.ts';

const FREE_TIER_MONTHLY_LIMIT = 4;

function currentMonth(): string {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabase = createUserClient(req);

    // Get the authenticated user
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Get subscription tier
    const { data: profile } = await supabase
      .from('user_profiles')
      .select('subscription_tier')
      .eq('id', user.id)
      .single();

    const tier = profile?.subscription_tier ?? 'free';

    // Pro tier: always allowed
    if (tier === 'pro') {
      return new Response(
        JSON.stringify({
          allowed: true,
          remaining: -1,
          limit: -1,
          tier: 'pro',
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Free tier: check usage
    const month = currentMonth();
    const { data: usage } = await supabase
      .from('usage_tracking')
      .select('summary_count')
      .eq('user_id', user.id)
      .eq('month', month)
      .single();

    const currentCount = usage?.summary_count ?? 0;
    const remaining = Math.max(
      0,
      FREE_TIER_MONTHLY_LIMIT - currentCount,
    );

    return new Response(
      JSON.stringify({
        allowed: remaining > 0,
        remaining,
        limit: FREE_TIER_MONTHLY_LIMIT,
        tier: 'free',
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('check-usage-limit error:', err);
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
```

**Step 2: Commit**

```bash
git add supabase/functions/check-usage-limit/index.ts
git commit -m "feat: add check-usage-limit edge function"
```

---

### Task 6: Add Test HTTP File and Final Verification

**Files:**
- Create: `supabase/functions/test.http`

**Step 1: Create test.http with sample curl commands**

```http
### Generate Weekly Summary (service role — for testing)
# Replace YOUR_SUPABASE_URL, YOUR_SERVICE_ROLE_KEY, and USER_ID
POST {{SUPABASE_URL}}/functions/v1/generate-weekly-summary
Authorization: Bearer {{SERVICE_ROLE_KEY}}
Content-Type: application/json

{
  "user_id": "{{USER_ID}}"
}

### Check Usage Limit (user JWT — for testing)
# Replace YOUR_SUPABASE_URL and USER_JWT
POST {{SUPABASE_URL}}/functions/v1/check-usage-limit
Authorization: Bearer {{USER_JWT}}
Content-Type: application/json

{}

### Expected Responses:

# generate-weekly-summary (success):
# {
#   "success": true,
#   "summary": "...",
#   "themes": ["..."],
#   "growth_observation": "...",
#   "prompts_created": 3,
#   "entries_processed": 5
# }

# generate-weekly-summary (no new entries):
# { "skipped": true, "reason": "no_new_entries" }

# generate-weekly-summary (rate limited):
# HTTP 429 { "allowed": false, "reason": "usage_limit_exceeded" }

# check-usage-limit (free tier):
# { "allowed": true, "remaining": 3, "limit": 4, "tier": "free" }

# check-usage-limit (pro tier):
# { "allowed": true, "remaining": -1, "limit": -1, "tier": "pro" }
```

**Step 2: Verify all files exist**

```bash
ls -la supabase/functions/_shared/
ls -la supabase/functions/generate-weekly-summary/
ls -la supabase/functions/check-usage-limit/
```

**Step 3: Verify Flutter project still passes (edge functions shouldn't affect it)**

```bash
flutter analyze
flutter test
```

**Step 4: Commit**

```bash
git add supabase/functions/test.http
git commit -m "docs: add test.http for edge function testing"
```

**Step 5: Final commit for Phase 5**

```bash
git status
git log --oneline -10
```

---

## Summary

| Task | Description |
|------|-------------|
| 1 | Create shared CORS helper |
| 2 | Create shared Supabase client helper (service role + user JWT) |
| 3 | Create shared Gemini 2.0 Flash API helper with structured output |
| 4 | Create generate-weekly-summary edge function (full AI pipeline) |
| 5 | Create check-usage-limit edge function |
| 6 | Add test.http file and final verification |
