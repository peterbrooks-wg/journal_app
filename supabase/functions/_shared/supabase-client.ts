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
