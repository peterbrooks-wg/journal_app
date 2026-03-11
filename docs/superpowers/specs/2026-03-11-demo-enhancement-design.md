# Demo Enhancement Design Spec

**Date:** 2026-03-11
**Goal:** Transform the Reflect app from a functional journaling prototype into a compelling leadership demo that proves the AI is the product and the Supabase + Gemini investment is worth it.

**Demo format:** Live walkthrough + screen recording. Must feel solid with no dead ends.

---

## 1. Scope

### Adding

| Enhancement | Purpose |
|---|---|
| Fix Supabase crash | Comment out `initSupabase()` so app runs without credentials |
| Seed 12–15 journal entries | Realistic entries across 3 weeks so the app feels lived-in |
| Bottom navigation bar | Home, Journal, Insights, Settings — feels like a shipping product |
| Summaries list screen | Weekly card stack with theme chips, entry count, preview text |
| Summary detail screen | Full AI summary, growth observation, 3 personalized prompts |
| Seed 3 weekly summaries | Realistic AI-written content tied to the seeded entries |
| Home screen: AI prompts | Replace generic prompts with personalized ones from latest summary |
| Settings screen (minimal) | User info, Pro badge, sign out button, visual preference rows |

### Not adding

- No real Supabase/Gemini calls — all mock data
- No subscription purchase flow — just show the Pro badge
- No push notifications
- No biometric lock
- No data export functionality

---

## 2. Model Changes

### AiSummary — add `growthObservation` field

The existing `AiSummary` model at `lib/shared/models/ai_summary.dart` needs a new field:

```dart
final String growthObservation; // The "Growth" callout text
```

Add to constructor, `fromJson`, and `toJson`. Run `build_runner` after.

The `weekEnd` date is **computed**, not stored: `weekStart.add(Duration(days: 6))`. Add a getter to the model:

```dart
DateTime get weekEnd => weekStart.add(const Duration(days: 6));
```

### AiPrompt — add `summaryId` field

The existing `AiPrompt` model at `lib/shared/models/ai_prompt.dart` needs a new field to link prompts to their parent summary:

```dart
final String summaryId; // Links to the AiSummary that generated this prompt
```

Add to constructor, `fromJson`, and `toJson`. Run `build_runner` after.

---

## 3. Architecture

### Data Flow

```
App starts → main.dart calls ref.read(demoDataProvider) after auth init
                                          ↓
DemoDataProvider (synchronous Provider) seeds:
  → journalProvider.notifier.seedEntries(List<JournalEntry>)
  → summaryProvider.notifier.seedSummaries(List<AiSummary>)
  → promptProvider.notifier.seedPrompts(List<AiPrompt>)
                                          ↓
HomeScreen ← personalized prompts from latestPromptsProvider
JournalList ← seeded entries from journalProvider (existing)
SummariesList ← summaryProvider (new)
SummaryDetail ← single summary by ID + its prompts
Settings ← authProvider (existing) + Pro badge (visual)
```

### New Providers

**`summary_provider.dart`:**
- `SummaryNotifier extends Notifier<List<AiSummary>>` — same pattern as `JournalNotifier`
- Methods: `seedSummaries(List<AiSummary>)` (bulk replace state), `getSummary(String id) → AiSummary?`
- `summaryProvider` — `NotifierProvider<SummaryNotifier, List<AiSummary>>`

**`prompt_provider.dart`:**
- `PromptNotifier extends Notifier<List<AiPrompt>>` — same pattern
- Methods: `seedPrompts(List<AiPrompt>)` (bulk replace state)
- `promptProvider` — `NotifierProvider<PromptNotifier, List<AiPrompt>>`
- `promptsForSummaryProvider(String summaryId)` — derived `Provider.family` that filters prompts by `summaryId`
- `latestPromptsProvider` — derived `Provider` that returns prompts for the newest summary (sorted by `weekStart`)

**`demo_data_provider.dart`:**
- A synchronous `Provider<void>` that:
  1. Calls `ref.read(journalProvider.notifier).seedEntries(...)` with all 15 entries
  2. Calls `ref.read(summaryProvider.notifier).seedSummaries(...)` with 3 summaries
  3. Calls `ref.read(promptProvider.notifier).seedPrompts(...)` with 9 prompts
- Triggered once from `main.dart` after `WidgetsFlutterBinding.ensureInitialized()`
- All data is hardcoded inline — no async, no loading states

**Bulk seeding on `JournalNotifier`:**

Add a `seedEntries(List<JournalEntry>)` method to the existing `JournalNotifier` that sets `state = entries` directly. The existing `addEntry()` auto-generates IDs and timestamps which conflicts with seeding past-dated entries.

### Adjusting `recentEntriesProvider`

The existing `recentEntriesProvider` filters to `DateTime.now().subtract(Duration(days: 7))`. Since demo entries are backdated to Feb 17–Mar 9, this would show nothing if the app runs after Mar 16.

**Fix:** Change `recentEntriesProvider` to show the most recent 5 entries regardless of date, with a fallback to the 7-day filter for production later. For the demo, `state.take(5).toList()` is sufficient since entries are sorted newest-first.

### Navigation

`StatefulShellRoute` wrapping four tabs so each preserves its own navigation stack:

| Tab | Icon (inactive/active) | Label | Route |
|---|---|---|---|
| Home | `home_outlined` / `home` | Home | `/` |
| Journal | `book_outlined` / `book` | Journal | `/journal` |
| Insights | `auto_awesome_outlined` / `auto_awesome` | Insights | `/summaries` |
| Settings | `settings_outlined` / `settings` | Settings | `/settings` |

**Router structure:**
- `/auth` and `/onboarding` remain as **top-level routes outside the shell** (no nav bar during auth flow)
- `StatefulShellRoute` wraps the four tab branches
- Each branch gets its own `GlobalKey<NavigatorState>` (required by GoRouter for `StatefulShellRoute`)
- `/summaries/:id` is a sub-route under the Insights branch
- `/journal/new` and `/journal/:id` are sub-routes under the Journal branch

**Nav bar styling:**
- Active tab color: accent (#7B9EA6)
- Inactive tab color: textSecondary (#6B7280)
- Labels on all tabs (discoverability for demo)

**FAB:** Each screen's individual `Scaffold` keeps its own FAB (no change to existing `HomeScreen` and `JournalListScreen` FABs). The `ScaffoldWithNavBar` widget only provides the `BottomNavigationBar` — it does **not** wrap a `Scaffold`. It uses a `Column` with the child body + nav bar, or a `Scaffold` with the `body` as the routed child and `bottomNavigationBar` as the nav bar. The child screens provide their own `Scaffold` with their own `floatingActionButton`. `SummariesListScreen` and `SettingsScreen` have no FAB.

### New Files

```
lib/shared/providers/summary_provider.dart
lib/shared/providers/prompt_provider.dart
lib/shared/providers/demo_data_provider.dart
lib/features/summaries/summaries_list_screen.dart   (replaces summaries_screen.dart)
lib/features/summaries/summary_detail_screen.dart
lib/features/summaries/widgets/summary_card.dart
lib/features/summaries/widgets/theme_chip.dart
lib/shared/widgets/scaffold_with_nav_bar.dart
```

**Note:** Delete the existing `lib/features/summaries/summaries_screen.dart` placeholder and replace with `summaries_list_screen.dart`. Update the import in `router.dart`.

### Modified Files

```
lib/shared/models/ai_summary.dart                 — add growthObservation field + weekEnd getter
lib/shared/models/ai_prompt.dart                   — add summaryId field
lib/shared/providers/journal_provider.dart          — add seedEntries() method
lib/main.dart                                      — comment out initSupabase(), trigger demo seed
lib/core/router.dart                               — add StatefulShellRoute, nav bar, /summaries/:id route
lib/features/journal/home_screen.dart              — swap generic prompts for latestPromptsProvider
lib/features/settings/settings_screen.dart         — replace placeholder with profile + Pro badge + sign out
```

Run `dart run build_runner build --delete-conflicting-outputs` after model changes.

---

## 4. Demo Data — The Narrative

Three weeks of entries tell a coherent story. Summaries reference specific entries. Prompts go deeper on themes. This is what makes the AI feel real.

The implementer writes full prose for each entry (50–150 words). Entries should read like real journal entries — informal, sometimes fragmented, emotionally honest. First person. No headers or structure — just flowing text.

Word counts per summary are computed from the sum of that week's seeded entries. The `wordCountTotal` field on `AiSummary` is set accordingly during seeding.

### Week 1: Feb 17–23 — Processing Frustration

**6 entries (~50–150 words each):**
- Monday Feb 17: Difficult standup, felt talked over by a colleague
- Tuesday Feb 18: Venting about the same dynamic, wondering if it's worth raising
- Wednesday Feb 19: Had a direct conversation with manager, mixed feelings
- Thursday Feb 20: Reflecting on why confrontation feels so hard
- Friday Feb 21: Short entry, just tired
- Saturday Feb 22: Morning run cleared the head, gratitude for the weekend

**Moods:** hard, hard, mixed, reflective, hard, good

**Summary themes:** `["work frustration", "communication", "boundaries"]`

**Summary text (full):**

> This was a week of friction — mostly at work, mostly around feeling unheard. Monday and Tuesday's entries carry real frustration about a recurring dynamic in standups where your ideas get talked over. By Wednesday you'd had a direct conversation with your manager about it, and the honesty in that entry is striking even if the outcome felt uncertain.
>
> What stands out is how your writing shifted across the week. Early entries were venting — getting the heat out. By Thursday you were asking deeper questions about why confrontation feels so loaded for you. That's a different kind of processing.
>
> Saturday's run entry was a release valve. You described the physical sensation of tension leaving your shoulders. Your body knew what it needed before your mind caught up.

**Growth observation:** "This is the first week you wrote about frustration in real time instead of days later. That immediacy — even when it's messy — is how self-awareness builds."

**Prompts:**
1. "What would it look like to set one small boundary at work this week?"
2. "Write about a time someone listened to you well. What did they do differently?"
3. "Your Saturday run shifted something. What other physical activities help you process?"

### Week 2: Feb 24–Mar 2 — Reconnecting

**4 entries:**
- Monday Feb 24: Old college friend texted out of the blue, made plans to catch up
- Wednesday Feb 26: Had dinner with the friend, deep conversation about how they've both changed
- Friday Feb 28: Reflecting on how friendships evolve, feeling grateful but also a little sad about time passing
- Sunday Mar 2: Quiet day, reading and journaling about identity

**Moods:** good, reflective, reflective, grateful

**Summary themes:** `["friendships", "nostalgia", "identity"]`

**Summary text (full):**

> A quieter week — and that seems intentional. After last week's intensity at work, you shifted your attention to relationships. The catalyst was an unexpected text from a college friend, which led to a dinner conversation that clearly meant a lot to you.
>
> Wednesday's entry has a warmth to it — you wrote about how you've both changed since college but the core of the friendship hasn't. There's vulnerability in naming that. Friday brought some melancholy about time passing, but it read more like appreciation than loss.
>
> Sunday you gave yourself a genuinely unstructured day. Reading, thinking, writing about who you're becoming. Weeks like this don't feel dramatic, but they're doing quiet, important work.

**Growth observation:** "Last week was heavy processing. This week you gave yourself space — reconnecting with someone who knows an earlier version of you. That's not avoidance, it's balance."

**Prompts:**
1. "What's one thing your college-age self would be proud of about who you are now?"
2. "Which friendships feel effortless? What makes them different from the ones that don't?"
3. "You mentioned feeling sad about time passing. What would you want to hold onto from right now?"

### Week 3: Mar 3–9 — Creative Tension

**5 entries:**
- Monday Mar 3: Excited about a side project idea (a design tool for nonprofits)
- Tuesday Mar 4: Started sketching it out, feeling energized
- Wednesday Mar 5: Self-doubt crept in — "who am I to build this?"
- Thursday Mar 6: Noticed the doubt pattern, wrote about the doubt itself instead of just feeling it
- Friday Mar 7: Mixed feelings, but decided to keep the sketches and revisit next weekend

**Moods:** good, good, mixed, reflective, mixed

**Summary themes:** `["career growth", "creative expression", "self-doubt"]`

**Summary text (full):**

> This week you navigated a tension between wanting more creative freedom and the security of your current role. Monday's entry had a spark of excitement about a side project idea — a design tool for nonprofits — and Tuesday you were sketching it out with real energy.
>
> By Wednesday the self-doubt arrived, right on schedule. "Who am I to build this?" is the exact question you've written variations of before. But here's what's different: Thursday's entry was the first time you wrote about the doubt itself rather than just feeling it. You named the pattern — excitement, then contraction — and sat with it instead of letting it shut you down.
>
> Friday's decision to keep the sketches and revisit them is quietly significant. You didn't abandon the idea. You didn't force it either. You held the tension.

**Growth observation:** "Two weeks ago you wrote about feeling stuck without exploring why. This week you actively questioned the pattern. You're building self-awareness, even when it's uncomfortable."

**Prompts (shown on Home screen):**
1. "What would you do with your creative energy if failure wasn't a factor?"
2. "Describe the version of yourself who pursued the side project. What does their week look like?"
3. "When did self-doubt last protect you from something real vs. hold you back from something good?"

---

## 5. Summaries List Screen

Replaces the existing `summaries_screen.dart` placeholder. New file: `summaries_list_screen.dart`.

Scrollable list of `SummaryCard` widgets, newest first. Uses `CustomScrollView` with slivers.

**Each card shows:**
- Week date range (e.g., "Mar 3 – Mar 9") — computed from `weekStart` and `weekEnd` getter
- Entry count + total word count (e.g., "5 entries · 1,240 words")
- 2-line preview of `summaryText` (first 120 characters + ellipsis)
- Theme chips (accent color, pill-shaped) using `ThemeChip` widget
- Tap → navigates to `/summaries/:id`

**Bottom of list:** A `SliverToBoxAdapter` at the end of the `CustomScrollView` containing the Pro badge pill — "Pro — Weekly AI Summaries" with `Icons.auto_awesome` icon. Not sticky — scrolls with the list.

**Empty state (defensive):** Icon + "Your first summary will appear after a week of journaling"

---

## 6. Summary Detail Screen

New route: `/summaries/:id` (sub-route under Insights branch).

Full-page view when tapping a summary card. Uses its own `Scaffold` with an `AppBar` back arrow.

**Layout (top to bottom):**
1. **Header:** Week date range + entry count (e.g., "Mar 3 – Mar 9 · 5 entries"), "Your Week" title below
2. **Theme chips:** Same `ThemeChip` widget as the list cards
3. **Summary text:** 2–3 paragraphs, warm and insightful tone. Use `textTheme.bodyLarge` (16dp) with `height: 1.6` for line spacing.
4. **Growth observation box:** Left-bordered container with `accent` color 3px border, light accent background fill. Label: `Icons.trending_up` icon + "Growth" text (uppercase, accent color). Observation text below in `bodyMedium`.
5. **Personalized prompts:** "Prompts for this week" heading (`titleMedium`), 3 `PromptCard` widgets (reuse existing widget from `lib/features/journal/widgets/prompt_card.dart`). Tap → navigates to `/journal/new`.

Prompts for this summary are read from `promptsForSummaryProvider(summary.id)`.

**Back navigation:** Standard AppBar back arrow → returns to summaries list (stays within the Insights tab navigation stack).

---

## 7. Settings Screen

Replaces the existing placeholder in `lib/features/settings/settings_screen.dart`.

**Layout (top to bottom):**

1. **Profile section:**
   - Initials avatar circle (48dp, accent background, white "J" text, `titleLarge`)
   - Display name: "Jordan" (`titleMedium`)
   - Email: "jordan@example.com" (`bodyMedium`, `textSecondary` color)

2. **Subscription section:**
   - "Pro" pill badge (accent background, white text, rounded)
   - Subtitle: "Weekly AI summaries · Personalized prompts" (`bodySmall`, `textSecondary`)

3. **Preferences section (visual only, no tap handlers):**
   - `ListTile` with "Notifications" title and a `Switch` widget (value: true, onChanged: null)
   - `ListTile` with "Daily reminder" title and trailing "8:00 AM" text

4. **Privacy section (visual only):**
   - `ListTile` with "Export my data" title and trailing chevron icon
   - `ListTile` with "Delete all data" title in red text and trailing chevron icon

5. **Sign out button:** `TextButton` at bottom, functional — calls `ref.read(authProvider.notifier).signOut()`, returns to login screen. Useful for re-demoing the onboarding flow.

Wrapped in a `ListView` for scrolling. Section headers use `bodySmall` uppercase text with `textSecondary` color and horizontal padding.

---

## 8. Home Screen Changes

Replace the hardcoded `_genericPrompts` list with prompts read from `latestPromptsProvider`. The 3 prompts from the latest weekly summary (Week 3) appear under "Prompts for you."

If `latestPromptsProvider` returns an empty list (shouldn't happen with demo data, but defensive), fall back to the existing generic prompts.

Each prompt now uses `AiPrompt.promptText` instead of a raw string. The `PromptCard` widget API stays the same — it already takes a `String promptText`.

---

## 9. Demo Walkthrough Script (5–7 minutes)

1. **Launch** → Auth screen → tap any sign-in method
2. **Onboarding** → swipe through 3 pages → "Get Started"
3. **Home screen** → greeting + personalized AI prompts + recent entries already populated
4. **Tap a prompt** → journal editor opens → show typing + word count + mood picker
5. **Back to Home** → new entry visible in recent list
6. **Tap Journal tab** → full entry list with search, show searching by keyword
7. **Tap Insights tab** → 3 weeks of AI summaries with theme chips
8. **Tap latest summary** → full detail: warm summary text, growth observation, personalized prompts
9. **Scroll through** → point out how themes evolve across weeks (frustration → reconnection → creativity)
10. **Tap Settings tab** → Pro badge, clean profile
11. **Key talking points during demo:**
    - "The AI reads across weeks — it notices patterns the user might miss"
    - "Prompts come from their actual writing, not a generic database"
    - "Cost is ~$0.07/user/month. At $6.99/month, that's 99% margin on the AI"
    - "We need Supabase for persistent storage + auth, and Gemini API for the summaries"

---

## 10. What This Doesn't Include

- Real API calls to Gemini (mock data only)
- Real Supabase persistence (in-memory only)
- Subscription purchase flow (Pro badge is visual)
- Push notifications
- Biometric lock
- Data export/delete functionality
- Theme tracking chart (Pro feature from PRD, deferred)
