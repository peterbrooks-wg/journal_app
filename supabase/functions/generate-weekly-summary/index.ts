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
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
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
        JSON.stringify({
          allowed: false,
          reason: 'usage_limit_exceeded',
        }),
        {
          status: 429,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
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
      throw new Error(
        `Failed to fetch entries: ${entriesError.message}`,
      );
    }

    if (!entries || entries.length === 0) {
      return new Response(
        JSON.stringify({ skipped: true, reason: 'no_new_entries' }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
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
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  } catch (err) {
    console.error('generate-weekly-summary error:', err);
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  }
});
