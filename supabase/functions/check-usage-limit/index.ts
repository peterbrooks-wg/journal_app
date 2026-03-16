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
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
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
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
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
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  } catch (err) {
    console.error('check-usage-limit error:', err);
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  }
});
