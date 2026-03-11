# Demo Enhancement Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the Reflect journaling app into a compelling leadership demo with seeded data, AI summaries screens, bottom navigation, and a settings screen.

**Architecture:** Add mock data providers that seed 15 journal entries, 3 AI summaries, and 9 prompts on startup. Build Summaries list + detail screens, a real Settings screen, and wrap all tabs in a StatefulShellRoute with bottom navigation. No backend calls — all in-memory.

**Tech Stack:** Flutter, Riverpod 3.x, GoRouter 17.x (StatefulShellRoute), json_serializable

**Spec:** `docs/superpowers/specs/2026-03-11-demo-enhancement-design.md`

---

## Chunk 1: Model Changes + Providers (Foundation)

### Task 1: Update AiSummary Model

**Files:**
- Modify: `lib/shared/models/ai_summary.dart`

- [ ] **Step 1: Add growthObservation field and weekEnd getter**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'ai_summary.g.dart';

/// A weekly AI-generated summary of journal entries.
@JsonSerializable(fieldRename: FieldRename.snake)
class AiSummary {
  final String id;
  final String userId;
  final DateTime weekStart;
  final String summaryText;
  final String growthObservation;
  final List<String> themes;
  final int entryCount;
  final int wordCountTotal;
  final DateTime createdAt;

  const AiSummary({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.summaryText,
    required this.growthObservation,
    required this.themes,
    required this.entryCount,
    required this.wordCountTotal,
    required this.createdAt,
  });

  /// End of the summary week (6 days after start).
  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  factory AiSummary.fromJson(Map<String, dynamic> json) =>
      _$AiSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AiSummaryToJson(this);
}
```

- [ ] **Step 2: Verify the file compiles**

```bash
flutter analyze lib/shared/models/ai_summary.dart
```

Expected: May warn about outdated `.g.dart` — that's OK, we run build_runner in Task 3.

- [ ] **Step 3: Commit**

```bash
git add lib/shared/models/ai_summary.dart
git commit -m "feat: add growthObservation field and weekEnd getter to AiSummary"
```

---

### Task 2: Update AiPrompt Model

**Files:**
- Modify: `lib/shared/models/ai_prompt.dart`

- [ ] **Step 1: Add summaryId field**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'ai_prompt.g.dart';

/// An AI-generated writing prompt for the user.
@JsonSerializable(fieldRename: FieldRename.snake)
class AiPrompt {
  final String id;
  final String userId;
  final String summaryId;
  final String promptText;
  final List<String> sourceThemes;
  final bool used;
  final DateTime? usedAt;
  final DateTime createdAt;

  const AiPrompt({
    required this.id,
    required this.userId,
    required this.summaryId,
    required this.promptText,
    required this.sourceThemes,
    required this.used,
    this.usedAt,
    required this.createdAt,
  });

  factory AiPrompt.fromJson(Map<String, dynamic> json) =>
      _$AiPromptFromJson(json);

  Map<String, dynamic> toJson() => _$AiPromptToJson(this);
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/shared/models/ai_prompt.dart
```

Expected: May warn about outdated `.g.dart` — that's OK, we run build_runner in Task 3.

- [ ] **Step 3: Commit**

```bash
git add lib/shared/models/ai_prompt.dart
git commit -m "feat: add summaryId field to AiPrompt for summary linkage"
```

---

### Task 3: Regenerate JSON Serialization Code

**Files:**
- Regenerate: `lib/shared/models/ai_summary.g.dart`
- Regenerate: `lib/shared/models/ai_prompt.g.dart`

- [ ] **Step 1: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: Successful generation with updated `.g.dart` files.

- [ ] **Step 2: Verify no analysis errors**

```bash
flutter analyze lib/shared/models/
```

Expected: No errors.

- [ ] **Step 3: Commit generated files**

```bash
git add lib/shared/models/ai_summary.g.dart lib/shared/models/ai_prompt.g.dart
git commit -m "chore: regenerate JSON serialization for updated models"
```

---

### Task 4: Add seedEntries to JournalNotifier + Fix recentEntriesProvider

**Files:**
- Modify: `lib/shared/providers/journal_provider.dart`

- [ ] **Step 1: Add seedEntries method and update recentEntriesProvider**

Add `seedEntries` method to `JournalNotifier` (after `getEntry` method, before `_countWords`):

```dart
  /// Bulk-replace entries with pre-built data.
  ///
  /// Used for demo seeding. Entries must have all fields set.
  void seedEntries(List<JournalEntry> entries) {
    state = entries;
  }
```

Replace the existing `recentEntriesProvider` (lines 74-79) with:

```dart
/// Most recent 5 entries for the home screen.
final recentEntriesProvider = Provider<List<JournalEntry>>((ref) {
  final entries = ref.watch(journalProvider);
  return entries.take(5).toList();
});
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/shared/providers/journal_provider.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/shared/providers/journal_provider.dart
git commit -m "feat: add seedEntries to JournalNotifier, show recent 5 entries on home"
```

---

### Task 5: Create Summary Provider

**Files:**
- Create: `lib/shared/providers/summary_provider.dart`

- [ ] **Step 1: Create summary_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_summary.dart';

/// Manages the list of AI-generated weekly summaries.
class SummaryNotifier extends Notifier<List<AiSummary>> {
  @override
  List<AiSummary> build() => [];

  /// Bulk-replace summaries with pre-built data.
  void seedSummaries(List<AiSummary> summaries) {
    state = summaries;
  }

  /// Get a single summary by ID, or null.
  AiSummary? getSummary(String id) {
    for (final summary in state) {
      if (summary.id == id) return summary;
    }
    return null;
  }
}

/// Global summaries provider.
final summaryProvider =
    NotifierProvider<SummaryNotifier, List<AiSummary>>(
  SummaryNotifier.new,
);
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/shared/providers/summary_provider.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/shared/providers/summary_provider.dart
git commit -m "feat: add SummaryNotifier with seedSummaries and getSummary"
```

---

### Task 6: Create Prompt Provider

**Files:**
- Create: `lib/shared/providers/prompt_provider.dart`

- [ ] **Step 1: Create prompt_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_prompt.dart';
import '../models/ai_summary.dart';
import 'summary_provider.dart';

/// Manages the list of AI-generated prompts.
class PromptNotifier extends Notifier<List<AiPrompt>> {
  @override
  List<AiPrompt> build() => [];

  /// Bulk-replace prompts with pre-built data.
  void seedPrompts(List<AiPrompt> prompts) {
    state = prompts;
  }
}

/// Global prompts provider.
final promptProvider =
    NotifierProvider<PromptNotifier, List<AiPrompt>>(
  PromptNotifier.new,
);

/// Prompts for a specific summary.
final promptsForSummaryProvider =
    Provider.family<List<AiPrompt>, String>((ref, summaryId) {
  final prompts = ref.watch(promptProvider);
  return prompts.where((p) => p.summaryId == summaryId).toList();
});

/// Prompts from the most recent summary (for the home screen).
final latestPromptsProvider = Provider<List<AiPrompt>>((ref) {
  final summaries = ref.watch(summaryProvider);
  final prompts = ref.watch(promptProvider);
  if (summaries.isEmpty) return [];

  // Find the newest summary by weekStart.
  final sorted = [...summaries]
    ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
  final latestId = sorted.first.id;

  return prompts.where((p) => p.summaryId == latestId).toList();
});
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/shared/providers/prompt_provider.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/shared/providers/prompt_provider.dart
git commit -m "feat: add PromptNotifier with promptsForSummary and latestPrompts providers"
```

---

### Task 7: Create Demo Data Provider

**Files:**
- Create: `lib/shared/providers/demo_data_provider.dart`

- [ ] **Step 1: Create demo_data_provider.dart**

This file contains all the hardcoded demo entries, summaries, and prompts. It's intentionally large — all the realistic content lives here.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_prompt.dart';
import '../models/ai_summary.dart';
import '../models/journal_entry.dart';
import 'journal_provider.dart';
import 'prompt_provider.dart';
import 'summary_provider.dart';

/// Seeds all demo data into providers on first read.
///
/// Call `ref.read(demoDataProvider)` once at startup.
final demoDataProvider = Provider<void>((ref) {
  ref.read(journalProvider.notifier).seedEntries(_demoEntries);
  ref.read(summaryProvider.notifier).seedSummaries(_demoSummaries);
  ref.read(promptProvider.notifier).seedPrompts(_demoPrompts);
});

// ---------------------------------------------------------------------------
// JOURNAL ENTRIES — 15 entries across 3 weeks
// ---------------------------------------------------------------------------

int _wordCount(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  return trimmed.split(RegExp(r'\s+')).length;
}

const _userId = 'mock-user';

// -- Week 1: Feb 17–22 (Processing Frustration) --

const _w1e1Content =
    'Had another one of those standups where I pitched an idea and Marcus just '
    'talked right over me. Like I wasn\'t even there. I could feel my face '
    'getting hot but I just went quiet. I hate that I do that — go silent '
    'instead of pushing back. It\'s been happening for weeks now and I keep '
    'telling myself it\'s not a big deal, but it is. It really is.';

const _w1e2Content =
    'Still thinking about yesterday. Talked to Sarah at lunch and she said '
    'she\'s noticed it too — Marcus does it to everyone, but especially in '
    'morning meetings. She asked if I was going to say something to our '
    'manager. I said I didn\'t know. Part of me thinks it\'s not worth the '
    'drama. Another part of me is tired of being the person who always '
    'lets it slide.';

const _w1e3Content =
    'I did it. Talked to Priya after our 1:1 about the standup dynamic. She '
    'listened, which I appreciated, but her response was kind of neutral — '
    '"I\'ll keep an eye on it." Not sure what I expected. Maybe something more '
    'concrete. But at least I said it out loud. My hands were literally '
    'shaking afterward. Mixed feelings. Proud I spoke up, unsure it\'ll '
    'change anything.';

const _w1e4Content =
    'Why is confrontation so hard for me? Even a mild, professional '
    'conversation with my manager left me drained for the rest of the day. '
    'I keep replaying it. Did I say too much? Not enough? I think the real '
    'issue isn\'t Marcus — it\'s that I\'ve spent years avoiding any kind of '
    'friction and now even small amounts feel enormous.';

const _w1e5Content =
    'Just tired today. Long week. Nothing specific to write about, just '
    'that heavy, end-of-week feeling. Looking forward to sleeping in '
    'tomorrow.';

const _w1e6Content =
    'Morning run along the river. It was cold enough to see my breath and '
    'something about that — the physical discomfort, the rhythm of my feet, '
    'the way the tension literally left my shoulders around mile two — I '
    'feel like a different person than I did yesterday. The work stuff is '
    'still there but it\'s smaller. My body needed this. Grateful for '
    'Saturday mornings.';

// -- Week 2: Feb 24–Mar 2 (Reconnecting) --

const _w2e1Content =
    'Out of nowhere, Jamie texted. We haven\'t talked in probably six months. '
    'They\'re going to be in town Wednesday and wanted to grab dinner. '
    'Immediately said yes. It\'s funny how some friendships can go dormant '
    'and then one text makes it feel like no time has passed at all. Already '
    'looking forward to it.';

const _w2e2Content =
    'Dinner with Jamie was everything. We ended up closing the restaurant — '
    'three hours just flew by. We talked about how different our lives look '
    'now compared to college. They\'re in a completely different career, '
    'living in a city I\'ve never visited. But the way we talk to each other '
    'hasn\'t changed. There\'s this shorthand that still works. I told them '
    'about the work stuff and they just got it, no explanation needed. I '
    'forgot how good it feels to be known like that.';

const _w2e3Content =
    'Been thinking about the dinner all day. There\'s something bittersweet '
    'about friendships that survive distance. You realize how much has '
    'changed — we\'re not the same people who stayed up arguing about '
    'philosophy at 2am. But maybe that\'s OK. Maybe the friendship doesn\'t '
    'need us to be those people anymore. I feel grateful and a little sad '
    'at the same time. Time just moves.';

const _w2e4Content =
    'Quiet Sunday. Read for most of the afternoon — that book about identity '
    'that\'s been on my nightstand for weeks. Something in the chapter about '
    'how we construct narratives about ourselves hit different after this '
    'week. The version of me Jamie knows, the version my coworkers see, the '
    'version I am when I\'m alone writing this. Are they all me? Which one '
    'is closest to the real thing? I don\'t think there\'s an answer but '
    'the question feels important.';

// -- Week 3: Mar 3–7 (Creative Tension) --

const _w3e1Content =
    'Had this idea on the train home — what if I built a simple design tool '
    'specifically for nonprofits? Most of the orgs I\'ve volunteered with '
    'struggle with basic visual design. They\'re using Canva templates that '
    'all look the same. Something purpose-built, with their constraints in '
    'mind — limited budgets, volunteer-run teams, need for accessibility. '
    'I\'m actually excited. Haven\'t felt this spark about a project in a '
    'while.';

const _w3e2Content =
    'Spent my lunch break sketching out the nonprofit design tool idea. '
    'Started mapping features — template library organized by use case '
    '(fundraiser flyers, social posts, annual reports), built-in '
    'accessibility checker, brand kit that even a volunteer can use. The '
    'more I sketch the more possibilities I see. I keep thinking about '
    'this even when I\'m supposed to be doing other things. That\'s usually '
    'a sign the idea has legs.';

const _w3e3Content =
    'And there it is. Woke up this morning and the first thought was "who '
    'am I to build this?" I don\'t have a design background. I\'m not a '
    'nonprofit expert. There are probably ten apps that already do this '
    'better. The excitement from Monday and Tuesday feels naive now. I '
    'know this is a pattern — I\'ve done this before with other ideas. '
    'Get excited, then talk myself out of it. But knowing it\'s a pattern '
    'doesn\'t make the doubt feel less real.';

const _w3e4Content =
    'Something interesting happened today. I was writing about the doubt '
    'and I caught myself doing the thing — the spiral. And instead of '
    'going deeper into it, I just... wrote about the spiral itself. Like '
    'watching it from outside. "Here\'s the part where I list all the '
    'reasons I\'m not qualified. Here\'s the part where I compare myself '
    'to people who\'ve already built something." Naming it didn\'t make '
    'it go away, but it made it smaller. Like it lost some power when I '
    'wrote it down as a pattern instead of a truth.';

const _w3e5Content =
    'End of the week. I didn\'t delete the sketches. I also didn\'t open '
    'them today. I think that\'s OK. The idea is sitting on my desk, '
    'literally — the notebook is right there. I told myself I\'d look at '
    'it again next weekend with fresh eyes. Not forcing it, not abandoning '
    'it. Just... holding it. Which feels like progress compared to how I '
    'usually handle these things.';

final _demoEntries = [
  // Week 3 (newest first)
  JournalEntry(id: 'w3e5', userId: _userId, content: _w3e5Content, wordCount: _wordCount(_w3e5Content), moodTag: 'mixed', createdAt: DateTime(2026, 3, 7, 20, 15), updatedAt: DateTime(2026, 3, 7, 20, 15)),
  JournalEntry(id: 'w3e4', userId: _userId, content: _w3e4Content, wordCount: _wordCount(_w3e4Content), moodTag: 'reflective', createdAt: DateTime(2026, 3, 6, 21, 30), updatedAt: DateTime(2026, 3, 6, 21, 30)),
  JournalEntry(id: 'w3e3', userId: _userId, content: _w3e3Content, wordCount: _wordCount(_w3e3Content), moodTag: 'mixed', createdAt: DateTime(2026, 3, 5, 7, 45), updatedAt: DateTime(2026, 3, 5, 7, 45)),
  JournalEntry(id: 'w3e2', userId: _userId, content: _w3e2Content, wordCount: _wordCount(_w3e2Content), moodTag: 'good', createdAt: DateTime(2026, 3, 4, 12, 30), updatedAt: DateTime(2026, 3, 4, 12, 30)),
  JournalEntry(id: 'w3e1', userId: _userId, content: _w3e1Content, wordCount: _wordCount(_w3e1Content), moodTag: 'good', createdAt: DateTime(2026, 3, 3, 18, 45), updatedAt: DateTime(2026, 3, 3, 18, 45)),
  // Week 2
  JournalEntry(id: 'w2e4', userId: _userId, content: _w2e4Content, wordCount: _wordCount(_w2e4Content), moodTag: 'grateful', createdAt: DateTime(2026, 3, 2, 16, 0), updatedAt: DateTime(2026, 3, 2, 16, 0)),
  JournalEntry(id: 'w2e3', userId: _userId, content: _w2e3Content, wordCount: _wordCount(_w2e3Content), moodTag: 'reflective', createdAt: DateTime(2026, 2, 28, 19, 30), updatedAt: DateTime(2026, 2, 28, 19, 30)),
  JournalEntry(id: 'w2e2', userId: _userId, content: _w2e2Content, wordCount: _wordCount(_w2e2Content), moodTag: 'reflective', createdAt: DateTime(2026, 2, 26, 22, 15), updatedAt: DateTime(2026, 2, 26, 22, 15)),
  JournalEntry(id: 'w2e1', userId: _userId, content: _w2e1Content, wordCount: _wordCount(_w2e1Content), moodTag: 'good', createdAt: DateTime(2026, 2, 24, 14, 0), updatedAt: DateTime(2026, 2, 24, 14, 0)),
  // Week 1
  JournalEntry(id: 'w1e6', userId: _userId, content: _w1e6Content, wordCount: _wordCount(_w1e6Content), moodTag: 'good', createdAt: DateTime(2026, 2, 22, 8, 30), updatedAt: DateTime(2026, 2, 22, 8, 30)),
  JournalEntry(id: 'w1e5', userId: _userId, content: _w1e5Content, wordCount: _wordCount(_w1e5Content), moodTag: 'hard', createdAt: DateTime(2026, 2, 21, 22, 0), updatedAt: DateTime(2026, 2, 21, 22, 0)),
  JournalEntry(id: 'w1e4', userId: _userId, content: _w1e4Content, wordCount: _wordCount(_w1e4Content), moodTag: 'reflective', createdAt: DateTime(2026, 2, 20, 20, 45), updatedAt: DateTime(2026, 2, 20, 20, 45)),
  JournalEntry(id: 'w1e3', userId: _userId, content: _w1e3Content, wordCount: _wordCount(_w1e3Content), moodTag: 'mixed', createdAt: DateTime(2026, 2, 19, 17, 30), updatedAt: DateTime(2026, 2, 19, 17, 30)),
  JournalEntry(id: 'w1e2', userId: _userId, content: _w1e2Content, wordCount: _wordCount(_w1e2Content), moodTag: 'hard', createdAt: DateTime(2026, 2, 18, 12, 45), updatedAt: DateTime(2026, 2, 18, 12, 45)),
  JournalEntry(id: 'w1e1', userId: _userId, content: _w1e1Content, wordCount: _wordCount(_w1e1Content), moodTag: 'hard', createdAt: DateTime(2026, 2, 17, 9, 30), updatedAt: DateTime(2026, 2, 17, 9, 30)),
];

// ---------------------------------------------------------------------------
// AI SUMMARIES — 3 weekly summaries
// ---------------------------------------------------------------------------

final _demoSummaries = [
  AiSummary(
    id: 'sum-w3',
    userId: _userId,
    weekStart: DateTime(2026, 3, 3),
    summaryText:
        'This week you navigated a tension between wanting more creative '
        'freedom and the security of your current role. Monday\'s entry had '
        'a spark of excitement about a side project idea — a design tool for '
        'nonprofits — and Tuesday you were sketching it out with real energy.\n\n'
        'By Wednesday the self-doubt arrived, right on schedule. "Who am I to '
        'build this?" is the exact question you\'ve written variations of '
        'before. But here\'s what\'s different: Thursday\'s entry was the first '
        'time you wrote about the doubt itself rather than just feeling it. '
        'You named the pattern — excitement, then contraction — and sat with '
        'it instead of letting it shut you down.\n\n'
        'Friday\'s decision to keep the sketches and revisit them is quietly '
        'significant. You didn\'t abandon the idea. You didn\'t force it '
        'either. You held the tension.',
    growthObservation:
        'Two weeks ago you wrote about feeling stuck without exploring why. '
        'This week you actively questioned the pattern. You\'re building '
        'self-awareness, even when it\'s uncomfortable.',
    themes: ['career growth', 'creative expression', 'self-doubt'],
    entryCount: 5,
    wordCountTotal: 413,
    createdAt: DateTime(2026, 3, 9, 8, 0),
  ),
  AiSummary(
    id: 'sum-w2',
    userId: _userId,
    weekStart: DateTime(2026, 2, 24),
    summaryText:
        'A quieter week — and that seems intentional. After last week\'s '
        'intensity at work, you shifted your attention to relationships. '
        'The catalyst was an unexpected text from a college friend, which led '
        'to a dinner conversation that clearly meant a lot to you.\n\n'
        'Wednesday\'s entry has a warmth to it — you wrote about how you\'ve '
        'both changed since college but the core of the friendship hasn\'t. '
        'There\'s vulnerability in naming that. Friday brought some melancholy '
        'about time passing, but it read more like appreciation than loss.\n\n'
        'Sunday you gave yourself a genuinely unstructured day. Reading, '
        'thinking, writing about who you\'re becoming. Weeks like this don\'t '
        'feel dramatic, but they\'re doing quiet, important work.',
    growthObservation:
        'Last week was heavy processing. This week you gave yourself space — '
        'reconnecting with someone who knows an earlier version of you. '
        'That\'s not avoidance, it\'s balance.',
    themes: ['friendships', 'nostalgia', 'identity'],
    entryCount: 4,
    wordCountTotal: 309,
    createdAt: DateTime(2026, 3, 2, 8, 0),
  ),
  AiSummary(
    id: 'sum-w1',
    userId: _userId,
    weekStart: DateTime(2026, 2, 17),
    summaryText:
        'This was a week of friction — mostly at work, mostly around feeling '
        'unheard. Monday and Tuesday\'s entries carry real frustration about a '
        'recurring dynamic in standups where your ideas get talked over. By '
        'Wednesday you\'d had a direct conversation with your manager about '
        'it, and the honesty in that entry is striking even if the outcome '
        'felt uncertain.\n\n'
        'What stands out is how your writing shifted across the week. Early '
        'entries were venting — getting the heat out. By Thursday you were '
        'asking deeper questions about why confrontation feels so loaded for '
        'you. That\'s a different kind of processing.\n\n'
        'Saturday\'s run entry was a release valve. You described the physical '
        'sensation of tension leaving your shoulders. Your body knew what it '
        'needed before your mind caught up.',
    growthObservation:
        'This is the first week you wrote about frustration in real time '
        'instead of days later. That immediacy — even when it\'s messy — is '
        'how self-awareness builds.',
    themes: ['work frustration', 'communication', 'boundaries'],
    entryCount: 6,
    wordCountTotal: 389,
    createdAt: DateTime(2026, 2, 23, 8, 0),
  ),
];

// ---------------------------------------------------------------------------
// AI PROMPTS — 3 per summary (9 total)
// ---------------------------------------------------------------------------

final _demoPrompts = [
  // Week 3 prompts (shown on Home screen)
  AiPrompt(id: 'p-w3-1', userId: _userId, summaryId: 'sum-w3', promptText: 'What would you do with your creative energy if failure wasn\'t a factor?', sourceThemes: ['creative expression', 'self-doubt'], used: false, createdAt: DateTime(2026, 3, 9, 8, 0)),
  AiPrompt(id: 'p-w3-2', userId: _userId, summaryId: 'sum-w3', promptText: 'Describe the version of yourself who pursued the side project. What does their week look like?', sourceThemes: ['career growth', 'creative expression'], used: false, createdAt: DateTime(2026, 3, 9, 8, 0)),
  AiPrompt(id: 'p-w3-3', userId: _userId, summaryId: 'sum-w3', promptText: 'When did self-doubt last protect you from something real vs. hold you back from something good?', sourceThemes: ['self-doubt'], used: false, createdAt: DateTime(2026, 3, 9, 8, 0)),
  // Week 2 prompts
  AiPrompt(id: 'p-w2-1', userId: _userId, summaryId: 'sum-w2', promptText: 'What\'s one thing your college-age self would be proud of about who you are now?', sourceThemes: ['nostalgia', 'identity'], used: false, createdAt: DateTime(2026, 3, 2, 8, 0)),
  AiPrompt(id: 'p-w2-2', userId: _userId, summaryId: 'sum-w2', promptText: 'Which friendships feel effortless? What makes them different from the ones that don\'t?', sourceThemes: ['friendships'], used: false, createdAt: DateTime(2026, 3, 2, 8, 0)),
  AiPrompt(id: 'p-w2-3', userId: _userId, summaryId: 'sum-w2', promptText: 'You mentioned feeling sad about time passing. What would you want to hold onto from right now?', sourceThemes: ['nostalgia', 'identity'], used: false, createdAt: DateTime(2026, 3, 2, 8, 0)),
  // Week 1 prompts
  AiPrompt(id: 'p-w1-1', userId: _userId, summaryId: 'sum-w1', promptText: 'What would it look like to set one small boundary at work this week?', sourceThemes: ['boundaries', 'communication'], used: false, createdAt: DateTime(2026, 2, 23, 8, 0)),
  AiPrompt(id: 'p-w1-2', userId: _userId, summaryId: 'sum-w1', promptText: 'Write about a time someone listened to you well. What did they do differently?', sourceThemes: ['communication'], used: false, createdAt: DateTime(2026, 2, 23, 8, 0)),
  AiPrompt(id: 'p-w1-3', userId: _userId, summaryId: 'sum-w1', promptText: 'Your Saturday run shifted something. What other physical activities help you process?', sourceThemes: ['boundaries'], used: false, createdAt: DateTime(2026, 2, 23, 8, 0)),
];
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/shared/providers/demo_data_provider.dart
```

Expected: No errors. The `_wordCount` helper and all string constants must be valid.

- [ ] **Step 3: Commit**

```bash
git add lib/shared/providers/demo_data_provider.dart
git commit -m "feat: add demo data provider with 15 entries, 3 summaries, 9 prompts"
```

---

### Task 8: Wire Demo Data into main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Comment out initSupabase and trigger demo seed**

Replace the full contents of `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'shared/providers/demo_data_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initSupabase(); // Disabled for demo — no credentials needed
  runApp(const ProviderScope(child: ReflectApp()));
}

/// Root widget for the Reflect journaling app.
class ReflectApp extends ConsumerWidget {
  const ReflectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seed demo data on first build.
    ref.read(demoDataProvider);

    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Reflect',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/main.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: disable Supabase init, seed demo data on startup"
```

---

## Chunk 2: Navigation + Summaries Screens

### Task 9: Create ScaffoldWithNavBar Widget

**Files:**
- Create: `lib/shared/widgets/scaffold_with_nav_bar.dart`

- [ ] **Step 1: Create scaffold_with_nav_bar.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';

/// Shell widget that provides the bottom navigation bar.
///
/// Child screens provide their own Scaffold (with optional FAB).
/// This widget only adds the BottomNavigationBar.
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        backgroundColor: AppTheme.surfaceWhite,
        indicatorColor: AppTheme.accent.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.accent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book, color: AppTheme.accent),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon:
                Icon(Icons.auto_awesome, color: AppTheme.accent),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon:
                Icon(Icons.settings, color: AppTheme.accent),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/shared/widgets/scaffold_with_nav_bar.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/shared/widgets/scaffold_with_nav_bar.dart
git commit -m "feat: add ScaffoldWithNavBar with 4-tab bottom navigation"
```

---

### Task 10: Create ThemeChip Widget

**Files:**
- Create: `lib/features/summaries/widgets/theme_chip.dart`

- [ ] **Step 1: Create theme_chip.dart**

```dart
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// A small pill displaying a summary theme label.
class ThemeChip extends StatelessWidget {
  final String label;

  const ThemeChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.accent,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/summaries/widgets/theme_chip.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/summaries/widgets/theme_chip.dart
git commit -m "feat: add ThemeChip widget for summary theme labels"
```

---

### Task 11: Create SummaryCard Widget

**Files:**
- Create: `lib/features/summaries/widgets/summary_card.dart`

- [ ] **Step 1: Create summary_card.dart**

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/ai_summary.dart';
import 'theme_chip.dart';

/// A card displaying a weekly summary preview.
class SummaryCard extends StatelessWidget {
  final AiSummary summary;
  final VoidCallback? onTap;

  const SummaryCard({super.key, required this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateRange =
        '${DateFormat.MMMd().format(summary.weekStart)} – '
        '${DateFormat.MMMd().format(summary.weekEnd)}';
    final stats =
        '${summary.entryCount} entries · '
        '${summary.wordCountTotal} words';
    final preview = summary.summaryText.length > 120
        ? '${summary.summaryText.substring(0, 120)}...'
        : summary.summaryText;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateRange, style: textTheme.labelSmall),
                  Text(stats, style: textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                preview,
                style: textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: summary.themes
                    .map((t) => ThemeChip(label: t))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/summaries/widgets/summary_card.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/summaries/widgets/summary_card.dart
git commit -m "feat: add SummaryCard widget for weekly summary previews"
```

---

### Task 12: Create Summaries List Screen

**Files:**
- Create: `lib/features/summaries/summaries_list_screen.dart`

**Note:** The old `summaries_screen.dart` placeholder is deleted in Task 14 when the router is rewritten, to avoid a broken import between commits.

- [ ] **Step 1: Create summaries_list_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/providers/summary_provider.dart';
import 'widgets/summary_card.dart';

/// Displays a scrollable list of weekly AI summaries.
class SummariesListScreen extends ConsumerWidget {
  const SummariesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(summaryProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: summaries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No summaries yet',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your first summary will appear after\na week of journaling',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final summary = summaries[index];
                      return SummaryCard(
                        summary: summary,
                        onTap: () =>
                            context.go('/summaries/${summary.id}'),
                      );
                    },
                    childCount: summaries.length,
                  ),
                ),
                // Pro badge at bottom
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.accent,
                              Color(0xFF5A7F87),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Pro — Weekly AI Summaries',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/summaries/summaries_list_screen.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/summaries/summaries_list_screen.dart
git commit -m "feat: add SummariesListScreen with summary cards and Pro badge"
```

---

### Task 13: Create Summary Detail Screen

**Files:**
- Create: `lib/features/summaries/summary_detail_screen.dart`

- [ ] **Step 1: Create summary_detail_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/providers/prompt_provider.dart';
import '../../shared/providers/summary_provider.dart';
import '../journal/widgets/prompt_card.dart';
import 'widgets/theme_chip.dart';

/// Full detail view for a weekly AI summary.
class SummaryDetailScreen extends ConsumerWidget {
  final String summaryId;

  const SummaryDetailScreen({super.key, required this.summaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(summaryProvider);
    final summary = summaries
        .cast<AiSummary?>()
        .firstWhere((s) => s?.id == summaryId, orElse: () => null);
    final prompts = ref.watch(promptsForSummaryProvider(summaryId));
    final textTheme = Theme.of(context).textTheme;

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Summary not found')),
      );
    }

    final dateRange =
        '${DateFormat.MMMd().format(summary.weekStart)} – '
        '${DateFormat.MMMd().format(summary.weekEnd)}';

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              '$dateRange · ${summary.entryCount} entries',
              style: textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text('Your Week', style: textTheme.titleLarge),
            const SizedBox(height: 16),

            // Theme chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: summary.themes
                  .map((t) => ThemeChip(label: t))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Summary text
            Text(
              summary.summaryText,
              style: textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),

            // Growth observation box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.08),
                border: const Border(
                  left: BorderSide(
                    color: AppTheme.accent,
                    width: 3,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: AppTheme.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'GROWTH',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary.growthObservation,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Personalized prompts
            if (prompts.isNotEmpty) ...[
              Text(
                'Prompts for this week',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...prompts.map(
                (prompt) => PromptCard(
                  promptText: prompt.promptText,
                  onTap: () => context.go('/journal/new'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/summaries/summary_detail_screen.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/summaries/summary_detail_screen.dart
git commit -m "feat: add SummaryDetailScreen with growth observation and prompts"
```

---

### Task 14: Rewrite Router with StatefulShellRoute

**Files:**
- Modify: `lib/core/router.dart`
- Delete: `lib/features/summaries/summaries_screen.dart`

- [ ] **Step 1: Delete old summaries placeholder**

```bash
rm lib/features/summaries/summaries_screen.dart
```

- [ ] **Step 2: Replace router.dart with StatefulShellRoute**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/journal/home_screen.dart';
import '../features/journal/journal_entry_screen.dart';
import '../features/journal/journal_list_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/summaries/summaries_list_screen.dart';
import '../features/summaries/summary_detail_screen.dart';
import '../shared/providers/auth_provider.dart';
import '../shared/widgets/scaffold_with_nav_bar.dart';

// Navigator keys for each tab branch.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _journalNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'journal');
final _summariesNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'summaries');
final _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

/// Creates the app router with auth-aware redirects.
GoRouter createRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = ref.read(authProvider);
      final isOnAuthPage = state.matchedLocation == '/auth';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      if (authStatus == AuthStatus.unauthenticated) {
        return isOnAuthPage ? null : '/auth';
      }

      if (authStatus == AuthStatus.onboarding) {
        return isOnOnboarding ? null : '/onboarding';
      }

      // Authenticated — redirect away from auth/onboarding.
      if (isOnAuthPage || isOnOnboarding) {
        return '/';
      }

      return null;
    },
    routes: <RouteBase>[
      // Auth routes — outside the shell (no nav bar).
      GoRoute(
        path: '/auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app — shell with bottom navigation.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 1: Journal
          StatefulShellBranch(
            navigatorKey: _journalNavigatorKey,
            routes: [
              GoRoute(
                path: '/journal',
                builder: (context, state) =>
                    const JournalListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) =>
                        const JournalEntryScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final entryId = state.pathParameters['id'];
                      return JournalEntryScreen(entryId: entryId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 2: Insights (Summaries)
          StatefulShellBranch(
            navigatorKey: _summariesNavigatorKey,
            routes: [
              GoRoute(
                path: '/summaries',
                builder: (context, state) =>
                    const SummariesListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final summaryId = state.pathParameters['id']!;
                      return SummaryDetailScreen(
                        summaryId: summaryId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 3: Settings
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) =>
                    const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Riverpod provider for the app router.
final routerProvider = Provider<GoRouter>((ref) {
  return createRouter(ref);
});
```

- [ ] **Step 3: Verify**

```bash
flutter analyze lib/core/router.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/core/router.dart && git add -u lib/features/summaries/summaries_screen.dart
git commit -m "feat: add StatefulShellRoute with 4-tab bottom navigation"
```

---

## Chunk 3: Settings + Home Screen + Final Verification

### Task 15: Build Settings Screen

**Files:**
- Modify: `lib/features/settings/settings_screen.dart`

- [ ] **Step 1: Replace settings_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../shared/providers/auth_provider.dart';

/// Settings screen with profile, subscription badge, and sign out.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'J',
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jordan', style: textTheme.titleMedium),
                    Text(
                      'jordan@example.com',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Subscription badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Weekly AI summaries · Personalized prompts',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Preferences
          _SectionHeader(text: 'PREFERENCES', textTheme: textTheme),
          SwitchListTile(
            title: const Text('Notifications'),
            value: true,
            onChanged: null,
            activeColor: AppTheme.accent,
          ),
          ListTile(
            title: const Text('Daily reminder'),
            trailing: Text(
              '8:00 AM',
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          const Divider(),

          // Privacy
          _SectionHeader(text: 'PRIVACY', textTheme: textTheme),
          ListTile(
            title: const Text('Export my data'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ),
          ListTile(
            title: Text(
              'Delete all data',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.red,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ),

          const Divider(),
          const SizedBox(height: 8),

          // Sign out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
              },
              child: const Text('Sign out'),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  final TextTheme textTheme;

  const _SectionHeader({required this.text, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/settings/settings_screen.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings/settings_screen.dart
git commit -m "feat: build settings screen with profile, Pro badge, and sign out"
```

---

### Task 16: Update Home Screen to Use AI Prompts

**Files:**
- Modify: `lib/features/journal/home_screen.dart`

- [ ] **Step 1: Replace home_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/providers/journal_provider.dart';
import '../../shared/providers/prompt_provider.dart';
import 'widgets/entry_card.dart';
import 'widgets/prompt_card.dart';

/// Home screen with greeting, prompts, and recent entries.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _fallbackPrompts = [
    'What are you grateful for today?',
    'What challenge taught you something this week?',
    'Describe a moment that made you smile recently.',
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentEntries = ref.watch(recentEntriesProvider);
    final aiPrompts = ref.watch(latestPromptsProvider);
    final textTheme = Theme.of(context).textTheme;

    // Use AI prompts if available, otherwise fall back to generic.
    final promptTexts = aiPrompts.isNotEmpty
        ? aiPrompts.map((p) => p.promptText).toList()
        : _fallbackPrompts;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  _greeting(),
                  style: textTheme.displayLarge,
                ),
              ),
            ),
            // Prompts section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Prompts for you',
                  style: textTheme.titleMedium,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: promptTexts
                      .map(
                        (prompt) => PromptCard(
                          promptText: prompt,
                          onTap: () => context.go('/journal/new'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            // Recent entries section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Recent entries',
                      style: textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/journal'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            if (recentEntries.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.edit_note_rounded,
                            size: 40,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start your first entry',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap the button below to begin writing',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = recentEntries[index];
                    return EntryCard(
                      entry: entry,
                      onTap: () =>
                          context.go('/journal/${entry.id}'),
                    );
                  },
                  childCount: recentEntries.length,
                ),
              ),
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/journal/new'),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/journal/home_screen.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/journal/home_screen.dart
git commit -m "feat: show AI prompts from latest summary on home screen"
```

---

### Task 17: Update Widget Test

**Files:**
- Modify: `test/widget_test.dart`

The existing test imports `ReflectApp` which now triggers `demoDataProvider`. The test should still pass since demo data seeding is synchronous and `SharedPreferences.setMockInitialValues({})` is already called.

- [ ] **Step 1: Run existing test**

```bash
flutter test test/widget_test.dart
```

Expected: PASS. If it fails due to the removed `initSupabase` import, the fix is already in main.dart (import removed). If it fails for another reason, check the error and fix.

- [ ] **Step 2: If test passes, commit (no changes needed)**

If test fails, fix and commit. Otherwise, no commit needed for this task.

---

### Task 18: Full Verification

- [ ] **Step 1: Clean build**

```bash
flutter pub get
flutter analyze
```

Expected: No errors. Warnings about unused imports are OK to fix.

- [ ] **Step 2: Run tests**

```bash
flutter test
```

Expected: All tests pass. If the test fails because `demoDataProvider` triggers an error, check that all providers are properly initialized in `ProviderScope`. The most likely fix is ensuring `SharedPreferences.setMockInitialValues({})` is called before `pumpWidget`.

- [ ] **Step 3: Run the app on a simulator**

```bash
flutter run
```

Walk through the demo script:
1. Auth → sign in → onboarding → home
2. Verify personalized prompts appear on home (not generic ones)
3. Verify recent entries are populated (5 most recent)
4. Verify summary cards show non-zero word counts (e.g., "413 words", not "0 words")
5. Tap Journal tab → verify entries with search
6. Tap Insights tab → verify 3 summary cards with theme chips
7. Tap a summary → verify detail with growth box and prompts
8. Tap Settings tab → verify profile, Pro badge, sign out
9. Sign out → verify returns to auth screen

- [ ] **Step 4: Fix any issues found during walkthrough**

- [ ] **Step 5: Final commit (only if there are uncommitted fixes)**

```bash
git status
git add <specific files that were fixed>
git commit -m "fix: address issues found during demo walkthrough"
```

---

## Summary

| Task | Description |
|------|-------------|
| 1 | Add growthObservation + weekEnd to AiSummary model |
| 2 | Add summaryId to AiPrompt model |
| 3 | Regenerate JSON serialization code |
| 4 | Add seedEntries to JournalNotifier + fix recentEntriesProvider |
| 5 | Create SummaryNotifier provider |
| 6 | Create PromptNotifier + derived providers |
| 7 | Create demo data provider with all seeded content |
| 8 | Wire demo data into main.dart |
| 9 | Create ScaffoldWithNavBar widget |
| 10 | Create ThemeChip widget |
| 11 | Create SummaryCard widget |
| 12 | Create SummariesListScreen |
| 13 | Create SummaryDetailScreen |
| 14 | Rewrite router with StatefulShellRoute |
| 15 | Build Settings screen |
| 16 | Update Home screen to use AI prompts |
| 17 | Update widget test |
| 18 | Full verification and walkthrough |
