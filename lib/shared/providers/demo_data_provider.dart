import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_prompt.dart';
import '../models/ai_summary.dart';
import '../models/journal_entry.dart';
import 'journal_provider.dart';
import 'prompt_provider.dart';
import 'summary_provider.dart';

/// Seeds all demo data into providers.
///
/// Call once from `main()` with the app's [ProviderContainer].
void seedDemoData(ProviderContainer container) {
  container.read(journalProvider.notifier).seedEntries(_demoEntries);
  container.read(summaryProvider.notifier).seedSummaries(_demoSummaries);
  container.read(promptProvider.notifier).seedPrompts(_demoPrompts);
}

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
