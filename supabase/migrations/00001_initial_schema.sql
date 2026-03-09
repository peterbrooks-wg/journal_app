-- Phase 2: Initial schema for Reflect journaling app
-- Tables: user_profiles, journal_entries, ai_summaries, ai_prompts,
--         running_summaries, usage_tracking
-- All tables have RLS enabled with per-user policies.

-- =============================================================
-- TABLE: user_profiles
-- =============================================================
create table public.user_profiles (
  id uuid references auth.users on delete cascade primary key,
  subscription_tier text not null default 'free'
    check (subscription_tier in ('free', 'pro')),
  onboarding_completed boolean not null default false,
  timezone text not null default 'America/Los_Angeles',
  fcm_token text,
  created_at timestamptz not null default now()
);

alter table public.user_profiles enable row level security;

create policy "Users can view own profile"
  on public.user_profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.user_profiles for update
  using (auth.uid() = id);

-- =============================================================
-- TABLE: journal_entries
-- =============================================================
create table public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade not null,
  content text not null,
  word_count integer generated always as (
    array_length(regexp_split_to_array(trim(content), '\s+'), 1)
  ) stored,
  mood_tag text check (
    mood_tag in ('good', 'hard', 'mixed', 'reflective', 'grateful')
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.journal_entries enable row level security;

create policy "Users can view own entries"
  on public.journal_entries for select
  using (auth.uid() = user_id);

create policy "Users can insert own entries"
  on public.journal_entries for insert
  with check (auth.uid() = user_id);

create policy "Users can update own entries"
  on public.journal_entries for update
  using (auth.uid() = user_id);

create policy "Users can delete own entries"
  on public.journal_entries for delete
  using (auth.uid() = user_id);

-- =============================================================
-- TABLE: ai_summaries
-- =============================================================
create table public.ai_summaries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade not null,
  week_start date not null,
  summary_text text not null,
  themes text[] not null default '{}',
  entry_count integer not null default 0,
  word_count_total integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.ai_summaries enable row level security;

create policy "Users can view own summaries"
  on public.ai_summaries for select
  using (auth.uid() = user_id);

create policy "Users can insert own summaries"
  on public.ai_summaries for insert
  with check (auth.uid() = user_id);

create policy "Users can update own summaries"
  on public.ai_summaries for update
  using (auth.uid() = user_id);

create policy "Users can delete own summaries"
  on public.ai_summaries for delete
  using (auth.uid() = user_id);

-- =============================================================
-- TABLE: ai_prompts
-- =============================================================
create table public.ai_prompts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade not null,
  prompt_text text not null,
  source_themes text[] not null default '{}',
  used boolean not null default false,
  used_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.ai_prompts enable row level security;

create policy "Users can view own prompts"
  on public.ai_prompts for select
  using (auth.uid() = user_id);

create policy "Users can insert own prompts"
  on public.ai_prompts for insert
  with check (auth.uid() = user_id);

create policy "Users can update own prompts"
  on public.ai_prompts for update
  using (auth.uid() = user_id);

create policy "Users can delete own prompts"
  on public.ai_prompts for delete
  using (auth.uid() = user_id);

-- =============================================================
-- TABLE: running_summaries
-- =============================================================
create table public.running_summaries (
  user_id uuid references auth.users on delete cascade primary key,
  summary_text text not null default '',
  last_entry_id uuid references public.journal_entries on delete set null,
  updated_at timestamptz not null default now()
);

alter table public.running_summaries enable row level security;

create policy "Users can view own running summary"
  on public.running_summaries for select
  using (auth.uid() = user_id);

create policy "Users can insert own running summary"
  on public.running_summaries for insert
  with check (auth.uid() = user_id);

create policy "Users can update own running summary"
  on public.running_summaries for update
  using (auth.uid() = user_id);

-- =============================================================
-- TABLE: usage_tracking
-- =============================================================
create table public.usage_tracking (
  user_id uuid references auth.users on delete cascade not null,
  month date not null,
  ai_prompt_requests integer not null default 0,
  summary_count integer not null default 0,
  primary key (user_id, month)
);

alter table public.usage_tracking enable row level security;

create policy "Users can view own usage"
  on public.usage_tracking for select
  using (auth.uid() = user_id);

create policy "Users can insert own usage"
  on public.usage_tracking for insert
  with check (auth.uid() = user_id);

create policy "Users can update own usage"
  on public.usage_tracking for update
  using (auth.uid() = user_id);

-- =============================================================
-- TRIGGER: auto-create user_profiles on auth signup
-- =============================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.user_profiles (id)
  values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
